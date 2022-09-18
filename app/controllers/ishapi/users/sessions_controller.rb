
class Ishapi::Users::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token

  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?
    # respond_with resource, location: after_sign_in_path_for(resource)

    ## Send the jwt to client
    @current_user = resource
    @jwt_token = encode(user_id: @current_user.id.to_s)
    @profile = @current_user.profile
    render 'ishapi/users/login', format: :json, layout: false
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
