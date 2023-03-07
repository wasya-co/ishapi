
class Ishapi::Users::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token

  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?


    ## Send the jwt to client
    @current_user = resource
    @current_profile = Ish::UserProfile.find_by({ email: @current_user.email })
    @jwt_token = encode(user_profile_id: @current_profile.id.to_s)
    render 'ishapi/user_profiles/login', format: :json, layout: false
  end

  private

  ## copy-pasted from application_controller
  ## jwt
  def decode(token)
    decoded = JWT.decode(token, Rails.application.secrets.secret_key_base.to_s)[0]
    HashWithIndifferentAccess.new decoded
  end

  ## copy-pasted from application_controller
  ## jwt
  def encode(payload, exp = 48.hours.from_now) # @TODO: definitely change, right now I expire once in 2 days.
    payload[:exp] = exp.to_i
    JWT.encode(payload, Rails.application.secrets.secret_key_base.to_s)
  end


end
