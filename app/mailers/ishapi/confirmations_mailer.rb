
class Ishapi::ConfirmationsMailer < Devise::Mailer
  # default from: '314658@gmail.com'
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`

  default template_path: 'ishapi/mailer' # to make sure that your mailer uses the devise views

  def confirmation_instructions(record, token, opts={})
    # headers["Custom-header"] = "Bar"
    super
  end

end