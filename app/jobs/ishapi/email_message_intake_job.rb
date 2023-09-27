
##
## 2023-02-26 _vp_ Let's go
## 2023-03-07 _vp_ Continue
##
## class name: EIJ
##
class Ishapi::EmailMessageIntakeJob < Ishapi::ApplicationJob

  queue_as :default

  ## For recursive parts of type `related`.
  ## Content dispositions:
  # "inline; creation-date=\"Tue, 11 Apr 2023 19:39:42 GMT\"; filename=image005.png; modification-date=\"Tue, 11 Apr 2023 19:47:53 GMT\"; size=14916",
  #
  ## Content Types:
  # "application/pdf; name=\"Securities Forward Agreement -- HaulHub Inc -- Victor Pudeyev -- 2021-10-26.docx.pdf\""
  # "image/jpeg; name=TX_DL_2.jpg"
  # "image/png; name=image005.png"
  # "multipart/alternative; boundary=_000_BL0PR10MB2913C560ADE059F0AB3A6D11829A9BL0PR10MB2913namp_",
  # "text/html; charset=utf-8"
  # "text/plain; charset=UTF-8"
  def churn_subpart message, part
    if part.content_disposition&.include?('attachment')
      ## @TODO: attachments !
      ;
    else
      if part.content_type.include?("multipart/related") ||
        part.content_type.include?("multipart/alternative")

        part.parts.each do |subpart|
          churn_subpart( message, subpart )
        end

      elsif part.content_type.include?('text/html')
        message.part_html = part.decoded

      elsif part.content_type.include?("text/plain")
        message.part_txt = part.decoded

      else
        puts! part.content_type, '444 No action for a part with this content_type'
      end
    end
  end

  ## From: https://stackoverflow.com/questions/24672834/how-do-i-remove-emoji-from-string/24673322
  def strip_emoji(text)
    text = text.force_encoding('utf-8').encode
    clean = ""

    # symbols & pics
    regex = /[\u{1f300}-\u{1f5ff}]/
    clean = text.gsub regex, ""

    # enclosed chars
    regex = /[\u{2500}-\u{2BEF}]/ # I changed this to exclude chinese char
    clean = clean.gsub regex, ""

    # emoticons
    regex = /[\u{1f600}-\u{1f64f}]/
    clean = clean.gsub regex, ""

    #dingbats
    regex = /[\u{2702}-\u{27b0}]/
    clean = clean.gsub regex, ""
  end

  def perform id
    stub = ::Office::EmailMessageStub.find id
    if !Rails.env.test?
      puts "Performing EmailMessageIntakeJob for object_key #{stub.object_key}"
    end
    if stub.state != ::Office::EmailMessageStub::STATE_PENDING
      raise "This stub has already been processed: #{stub.id.to_s}."
      return
    end
    client = Aws::S3::Client.new({
      region:            ::S3_CREDENTIALS[:region_ses],
      access_key_id:     ::S3_CREDENTIALS[:access_key_id_ses],
      secret_access_key: ::S3_CREDENTIALS[:secret_access_key_ses],
    })

    _mail              = client.get_object( bucket: ::S3_CREDENTIALS[:bucket_ses], key: stub.object_key ).body.read
    the_mail           = Mail.new(_mail)
    message_id         = the_mail.header['message-id'].decoded
    in_reply_to_id     = the_mail.header['in-reply-to']&.to_s
    email_inbox_tag_id = WpTag.emailtag(WpTag::INBOX).id

    if !the_mail.to
      the_mail.to = [ 'NO-RECIPIENT' ]
    end


    subject   = strip_emoji the_mail.subject
    subject ||= '(wco no subject)'

    @message   = ::Office::EmailMessage.where( message_id: message_id ).first
    @message ||= ::Office::EmailMessage.new
    @message.assign_attributes({
      raw: _mail,

      message_id:     message_id,
      in_reply_to_id: in_reply_to_id,

      object_key:  stub.object_key,
      # object_path: stub.object_path,

      subject: subject,
      date:    the_mail.date,

      from:  the_mail.from ? the_mail.from[0] : "nobody@unknown.domain",
      froms: the_mail.from,

      to:  the_mail.to ? the_mail.to[0] : nil,
      tos: the_mail.to,

      cc:  the_mail.cc ? the_mail.cc[0] : nil,
      ccs:  the_mail.cc,

      # bccs: the_mail.bcc,
    })
    if the_mail.body.preamble.present?
      @message.preamble = the_mail.body.preamble
    end
    if the_mail.body.epilogue.present?
      @message.epilogue = the_mail.body.epilogue
    end

    ## Parts
    the_mail.parts.each do |part|
      churn_subpart( @message, part )
    end

    if the_mail.parts.length == 0
      body = the_mail.body.decoded.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
      if the_mail.content_type&.include?('text/html')
        @message.part_html = body
      elsif the_mail.content_type&.include?('text/plain')
        @message.part_txt = body
      elsif the_mail.content_type.blank?
        @message.part_txt = body
      else
        throw "mail body of unknown type: #{the_mail.content_type}"
      end
    end

    ## Attachments
    the_mail.attachments.each do |att|
      photo = Photo.new({
        content_type:      att.content_type.split(';')[0],
        original_filename: att.content_type_parameters[:name],
        image_data:        att.body.encoded,
        email_message_id: @message.id,
      })
      photo.decode_base64_image
      photo.save
    end

    ## Leadset, Lead
    domain  = @message.from.split('@')[1] rescue 'unknown.domain'
    leadset = Leadset.find_or_create_by( company_url: domain )
    lead    = Lead.find_or_create_by( email: @message.from, m3_leadset_id: leadset.id )

    ## Conversation
    if in_reply_to_id
      in_reply_to_msg = ::Office::EmailMessage.where({ message_id: in_reply_to_id }).first
      if !in_reply_to_msg
        conv = ::Office::EmailConversation.find_or_create_by({
          subject: @message.subject,
        })
        in_reply_to_msg = ::Office::EmailMessage.find_or_create_by({
          message_id: in_reply_to_id,
          email_conversation_id: conv.id,
        })
      end
      conv = in_reply_to_msg.email_conversation
    else
      conv = ::Office::EmailConversation.find_or_create_by({
        subject: @message.subject,
      })
    end
    @message.update_attributes({ email_conversation_id: conv.id })
    conv.update_attributes({
      state:     Conv::STATE_UNREAD,
      latest_at: the_mail.date || Time.now.to_datetime,
      from_emails: conv.from_emails + the_mail.from,
    })
    conv.add_tag( ::WpTag::INBOX )
    conv_lead_tie = Office::EmailConversationLead.find_or_create_by({
      lead_id: lead.id,
      email_conversation_id: conv.id,
    })


    ## Actions & Filters
    email_filters = Office::EmailFilter.active
    email_filters.each do |filter|
      if ( filter.from_regex.blank? ||     @message.from.match(                 filter.from_regex    ) ) &&
         ( filter.from_exact.blank? ||     @message.from.downcase.include?(     filter.from_exact&.downcase ) ) &&
         ( filter.body_exact.blank? ||     @message.part_html&.include?(         filter.body_exact    ) ) &&
         ( filter.subject_regex.blank? ||  @message.subject.match(              filter.subject_regex ) ) &&
         ( filter.subject_exact.blank? ||  @message.subject.downcase.include?(  filter.subject_exact&.downcase ) )

        # || MiaTagger.analyze( @message.part_html, :is_spammy_recruite ).score > .5

        puts! "applying filter #{filter} to conv #{conv}" if DEBUG

        @message.apply_filter( filter )
      end
    end

    stub.update_attributes({ state: ::Office::EmailMessageStub::STATE_PROCESSED })

    ## Notification
    conv = Conv.find( conv.id )
    if conv.in_emailtag? WpTag::INBOX
      out = ::Ishapi::ApplicationMailer.forwarder_notify( @message.id.to_s )
      Rails.env.production? ? out.deliver_later : out.deliver_now
    end

  end

end
EIJ = Ishapi::EmailMessageIntakeJob
