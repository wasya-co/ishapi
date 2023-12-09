
##
## 2023-02-26 _vp_ Let's go
## 2023-03-07 _vp_ Continue
##
## class name: EIJ
##
class Ishapi::EmailMessageIntakeJob < Ishapi::ApplicationJob

  queue_as :default

=begin

  ## Mongo::Error::MaxBSONSize: The document exceeds maximum allowed BSON object size after serialization (on 10.138.2.145)
  object_key = 'k9n9qo03fii2in3ocj977nac0vj5djn07e110bg1'

  object_key = 'hlbg24s1ov5k7irgmqsrjp0kl95vpik8t1esvs81'
  MsgStub.where({ object_key: object_key }).delete

  stub = MsgStub.create!({ object_key: object_key })
  id = stub.id

  Ishapi::EmailMessageIntakeJob.perform_now( stub.id.to_s )

=end
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

      raw                = client.get_object( bucket: ::S3_CREDENTIALS[:bucket_ses], key: stub.object_key ).body.read
      the_mail           = Mail.new( raw )
      message_id         = the_mail.header['message-id']&.decoded
      message_id       ||= "#{the_mail.date.iso8601}::#{the_mail.from}"
      in_reply_to_id     = the_mail.header['in-reply-to']&.to_s
      email_inbox_tag_id = WpTag.emailtag(WpTag::INBOX).id
      the_mail.to        = [ 'NO-RECIPIENT' ] if !the_mail.to
      subject            = ::Msg.strip_emoji( the_mail.subject || '(wco-no-subject)' )


      ## Conversation
      if in_reply_to_id
        in_reply_to_msg = ::Office::EmailMessage.where({ message_id: in_reply_to_id }).first
        if !in_reply_to_msg
          conv = ::Office::EmailConversation.find_or_create_by({
            subject: subject,
          })
          in_reply_to_msg = ::Office::EmailMessage.find_or_create_by({
            message_id: in_reply_to_id,
            email_conversation_id: conv.id,
          })
        end
        conv = in_reply_to_msg.email_conversation
      else
        conv = ::Office::EmailConversation.find_or_create_by({
          subject: subject,
        })
      end

      @message   = ::Office::EmailMessage.where( message_id: message_id ).first
      @message ||= ::Office::EmailMessage.create({
        # raw: raw,
        email_conversation_id: conv.id,

        message_id:     message_id,
        in_reply_to_id: in_reply_to_id,

        object_key:  stub.object_key,

        subject: subject,
        date:    the_mail.date,

        from:  the_mail.from ? the_mail.from[0] : "nobody@unknown-doma.in",
        froms: the_mail.from,

        to:  the_mail.to ? the_mail.to[0] : nil,
        tos: the_mail.to,

        cc:  the_mail.cc ? the_mail.cc[0] : nil,
        ccs:  the_mail.cc,
      })
      if !@message.persisted?
        throw "Could not create email_message: #{@message.errors.full_messages.join(', ')} ."
      end

      ## Parts
      the_mail.parts.each do |part|
        @message.churn_subpart( part )
      end
      @message.save

      if the_mail.parts.length == 0
        body = the_mail.body.decoded.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
        if the_mail.content_type&.include?('text/html')
          @message.part_html = body
        elsif the_mail.content_type&.include?('text/plain')
          @message.part_txt = body
        elsif the_mail.content_type.blank?
          @message.part_txt = body
        else
          @message.logs.push "mail body of unknown type: #{the_mail.content_type}"
        end
        @message.save
      end

      ## Attachments
      the_mail.attachments.each do |att|
        @message.save_attachment( att )
      end

      if !@message.save
        puts! @message.errors.full_messages.join(", "), "Could not save @message"
      end

      ## Leadset, Lead
      domain  = @message.from.split('@')[1] rescue 'unknown.domain'
      leadset = Leadset.find_or_create_by( company_url: domain )
      lead    = Lead.find_or_create_by( email: @message.from, m3_leadset_id: leadset.id )
      the_mail.cc&.each do |cc|
        domain  = cc.split('@')[1] rescue 'unknown.domain'
        leadset = Leadset.find_or_create_by( company_url: domain )
        Lead.find_or_create_by( email: cc, m3_leadset_id: leadset.id )
      end

      # @message.update_attributes({ email_conversation_id: conv.id })
      conv.update_attributes({
        state:       Conv::STATE_UNREAD,
        latest_at:   the_mail.date || Time.now.to_datetime,
        from_emails: ( conv.from_emails + the_mail.from ).uniq,
        preview: @message.body_sanitized[0...200],
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

          # puts! "applying filter #{filter} to conv #{conv}" if DEBUG

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
