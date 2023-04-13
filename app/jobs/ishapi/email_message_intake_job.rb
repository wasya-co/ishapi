
##
## 2023-02-26 _vp_ Let's go
## 2023-03-02 _vp_ Continue
## 2023-03-07 _vp_ Continue
##
## class name: EIJ
##
class Ishapi::EmailMessageIntakeJob < Ishapi::ApplicationJob

  # include Sidekiq::Worker ## From: https://stackoverflow.com/questions/59114063/sidekiq-options-giving-sidekiqworker-cannot-be-included-in-an-activejob-for

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
      region:            ::S3_CREDENTIALS[:region],
      access_key_id:     ::S3_CREDENTIALS[:access_key_id],
      secret_access_key: ::S3_CREDENTIALS[:secret_access_key] })

    _mail              = client.get_object( bucket: ::S3_CREDENTIALS[:bucket_ses], key: stub.object_key ).body.read
    the_mail           = Mail.new(_mail)
    message_id         = the_mail.header['message-id'].decoded
    in_reply_to_id     = the_mail.header['in-reply-to']&.to_s
    email_inbox_tag_id = WpTag.emailtag(WpTag::INBOX).id

    if !the_mail.to
      the_mail.to = [ 'NO-RECIPIENT' ]
    end

    @message = ::Office::EmailMessage.where( message_id: message_id ).first
    @message ||= ::Office::EmailMessage.new
    @message.assign_attributes({
      raw: _mail,

      message_id:     message_id,
      in_reply_to_id: in_reply_to_id,

      object_key:  stub.object_key,
      # object_path: stub.object_path,

      subject: the_mail.subject,
      date:    the_mail.date,

      from:  the_mail.from[0],
      froms: the_mail.from,

      to:  the_mail.to[0],
      tos: the_mail.to,

      ccs:  the_mail.cc,
      bccs: the_mail.bcc,
    })
    if the_mail.body.preamble.present?
      @message.preamble = the_mail.body.preamble
    end
    if the_mail.body.epilogue.present?
      @message.epilogue = the_mail.body.epilogue
    end

    the_mail.parts.each do |part|
      churn_subpart( @message, part )
    end

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

    if the_mail.parts.length == 0
      body = the_mail.body.decoded.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
      if the_mail.content_type.include?('text/html')
        @message.part_html = body
      elsif the_mail.content_type.include?('text/plain')
        @message.part_txt = body
      else
        throw "mail body of unknown type: #{the_mail.content_type}"
      end
    end

    ## Conversation
    if in_reply_to_id
      in_reply_to_msg = ::Office::EmailMessage.where({ message_id: in_reply_to_id }).first
      if !in_reply_to_msg
        conv = ::Office::EmailConversation.find_or_create_by({
          subject: the_mail.subject,
        })
        in_reply_to_msg = ::Office::EmailMessage.find_or_create_by({
          message_id: in_reply_to_id,
          email_conversation_id: conv.id,
        })
      end
      conv = in_reply_to_msg.email_conversation
    else
      conv = ::Office::EmailConversation.find_or_create_by({
        subject: the_mail.subject,
      })
    end
    @message.email_conversation_id = conv.id
    conv.update_attributes({
      state: Conv::STATE_UNREAD,
      latest_at: the_mail.date || Time.now.to_datetime,
      wp_term_ids: ( [ email_inbox_tag_id ] + conv.wp_term_ids + stub.wp_term_ids ).uniq,
    })

    ## Leadset
    domain = @message.from.split('@')[1]
    leadset = Leadset.find_or_create_by( company_url: domain )

    ## Lead
    lead = Lead.find_or_create_by( email: @message.from, m3_leadset_id: leadset.id )
    conv.lead_ids = conv.lead_ids.push( lead.id ).uniq

    ## Actions & Filters
    email_filters = Office::EmailFilter.active
    email_filters.each do |filter|
      if ( filter.from_regex.blank? ||     @message.from.match(      filter.from_regex ) ) &&
         ( filter.body_regex.blank? ||     @message.part_html.match( filter.body_regex ) ) &&
         ( filter.subject_regex.blank? ||  @message.subject.match(   filter.subject_regex ) )
        # || MiaTagger.analyze( @message.part_html, :is_spammy_recruite ).score > .5

        @message.apply_filter( filter )
      end
    end

    ## Save to exit
    flag = @message.save
    # if flag
    #   puts! @message.message_id, 'Saved this message'
    # else
    #   puts! @message.errors.full_messages.join(', '), 'Cannot save email_message'
    # end
    conv.save
    stub.update_attributes({ state: ::Office::EmailMessageStub::STATE_PROCESSED })

    ## Notification
    if conv.wp_term_ids.include?( email_inbox_tag_id )
      out = ::Ishapi::ApplicationMailer.forwarder_notify( @message.id.to_s )
      Rails.env.production? ? out.deliver_later : out.deliver_now
    end

  end

end
EIJ = Ishapi::EmailMessageIntakeJob
