
class Ishapi::Users::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token

  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?
    # respond_with resource, location: after_sign_in_path_for(resource)

    ## Send the jwt to client
    @jwt_token = encode(user_id: @current_user.id.to_s)
    @profile = @current_user.profile
    render 'users/login'
  end

end
