
class Ishapi::ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@wasya.co'
  layout 'mailer'

  def forwarder_notify msg_id
    @msg = ::Office::EmailMessage.find msg_id
    mail( to: 'piousbox@gmail.com',
          subject: "FWD_Notify: #{@msg.subject}" )
  end

end

