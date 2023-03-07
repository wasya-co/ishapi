
=begin

m_id_2 = "2021-07-12T19_17_26Fpedidos_jmc2_gmail_com"
stub = Stub.new( object_key: m_id_2 )
stub = Stub.find_by( object_key: m_id_2 )
stub.update_attribute(:state, 'state_pending')
Ishapi::EmailMessageIntakeJob.perform_now( stub.id.to_s )


=end
##
## 2023-02-26 _vp_ let's go
## 2023-03-02 _vp_ Continue
## 2023-03-07 _vp_ Continue
##
class Ishapi::EmailMessageIntakeJob < Ishapi::ApplicationJob

  # include Sidekiq::Worker ## From: https://stackoverflow.com/questions/59114063/sidekiq-options-giving-sidekiqworker-cannot-be-included-in-an-activejob-for

  queue_as :default

  ## For recursive parts of type `related`.
  ## Content Types:
  # "text/html; charset=utf-8"
  # "application/pdf; name=\"Securities Forward Agreement -- HaulHub Inc -- Victor Pudeyev -- 2021-10-26.docx.pdf\""
  # "image/jpeg; name=TX_DL_2.jpg"
  # "text/plain; charset=UTF-8"
  def churn_subpart message, part
    if part.content_type.include?("multipart/related")

      part.parts.each do |subpart|
        churn_subpart( message, subpart )
      end

    elsif part.content_type.include?('text/html')
      message.part_html = part.decoded

    elsif part.content_type.include?("text/plain")
      message.part_txt = part.decoded

    else
      ## @TODO: attachments !
      puts! part.content_type, '444 No action for a part with this content_type'
    end

    return nil
  end

  def perform id
    stub = ::Office::EmailMessageStub.find id
    puts "Performing EmailMessageIntakeJob for message_id #{stub.object_key}"
    if stub.state != ::Office::EmailMessageStub::STATE_PENDING
      raise "This stub has already been processed: #{stub.id.to_s}."
      return
    end
    client = Aws::S3::Client.new({
      region:            ::S3_CREDENTIALS[:region],
      access_key_id:     ::S3_CREDENTIALS[:access_key_id],
      secret_access_key: ::S3_CREDENTIALS[:secret_access_key] })

    _mail          = client.get_object( bucket: ::S3_CREDENTIALS[:bucket_ses], key: stub.object_key ).body.read
    the_mail       = Mail.new(_mail)
    message_id     = the_mail.header['message-id'].decoded ## == stub.object_key
    in_reply_to_id = the_mail.header['in-reply-to']&.to_s

    @message = ::Office::EmailMessage.where( message_id: message_id ).first
    @message ||= ::Office::EmailMessage.new
    @message.assign_attributes({
      raw: _mail,

      message_id:     message_id,
      in_reply_to_id: in_reply_to_id,

      object_key:  stub.object_key,
      object_path: stub.object_path,

      subject: the_mail.subject,
      date:    the_mail.date,

      from:  the_mail.from[0],
      froms: the_mail.from,

      to:  the_mail.to[0],
      tos: the_mail.to,

      ccs:  the_mail.cc,
      bccs: the_mail.bcc,
    })

    the_mail.parts.each do |part|
      churn_subpart( @message, part )
    end

    ## Conversation
    if in_reply_to_id
      in_reply_to_msg = ::Office::EmailMessage.where({ message_id: in_reply_to_id }).first
      if !in_reply_to_msg
        conv = ::Office::EmailConversation.create!({
          subject: the_mail.subject,
          latest_at: the_mail.date,
        })
        in_reply_to_msg = ::Office::EmailMessage.create!({
          message_id: in_reply_to_id,
          email_conversation_id: conv.id,
        })
      end
      conv = in_reply_to_msg.email_conversation
    else
      conv = ::Office::EmailConversation.create!({
        subject: the_mail.subject,
        latest_at: the_mail.date,
      })
    end
    @message.email_conversation_id = conv.id
    conv.update_attributes({
      state: Conv::STATE_UNREAD,
      latest_at: the_mail.date,
      term_ids: (conv.term_ids + stub.term_ids).uniq,
    })

    ## Leadset
    domain = @message.from.split('@')[1]
    leadset = Leadset.where( company_url: domain ).first
    if !leadset
      leadset = Leadset.create!( company_url: domain, name: domain )
    end

    ## Lead
    lead = Lead.where( email: @message.from ).first
    if !lead
      lead = Lead.new( email: @message.from )
      lead.leadsets.push( leadset )
      lead.save!
    end
    conv.lead_ids = conv.lead_ids.push( lead.id ).uniq

    ## Actions & Filters
    inbox_tag = WpTag.email_inbox_tag
    @message.add_tag( inbox_tag )
    conv.add_tag( inbox_tag )

    email_filters = Office::EmailFilter.active
    email_filters.each do |filter|
      if @message.from.match( filter.from_regex ) # || @message.part_html.match( filter.body_regex ) ) # || MiaTagger.analyze( @message.part_html, :is_spammy_recruite ).score > .5

        @message.apply_filter( filter )
      end
    end

    ## Save to exit
    flag = @message.save
    if flag
      puts! @message.message_id, 'Saved this message'
    else
      puts! @message.errors.full_messages.join(', '), 'Cannot save email_message'
    end
    conv.save
    stub.update_attributes({ state: ::Office::EmailMessageStub::STATE_PROCESSED })

    ## Notification
    if @message.wp_term_ids.include?( inbox_tag.id )
      # @TODO: send android notification _vp_ 2023-03-01
      ::Ishapi::ApplicationMailer.forwarder_notify( @message.id.to_s ).deliver_later
    end

  end

end
EIJ = Ishapi::EmailMessageIntakeJob
