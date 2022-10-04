
class Ishapi::Users::RegistrationsController < Devise::RegistrationsController
  skip_before_action :verify_authenticity_token

  def create
    build_resource(sign_up_params)
    resource.save
    user_profile = Ish::UserProfile.create({ email: resource.email })
    yield resource if block_given?
    if resource.persisted?
      render json: {
        status: :ok,
        message: "You have successfully registered! Please verify your email by clicking on a link we just sent you, before logging in.",
      }, status: 200

      # if resource.active_for_authentication?
      #   set_flash_message! :notice, :signed_up
      #   sign_up(resource_name, resource)
      #   respond_with resource, location: after_sign_up_path_for(resource)
      # else
      #   set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
      #   expire_data_after_sign_in!
      #   respond_with resource, location: after_inactive_sign_up_path_for(resource)
      # end
    else
      render json: {
        status: :not_ok,
        message: "Cannot register: #{resource.errors.full_messages.join(', ')}",
      }, status: 400

      # clean_up_passwords resource
      # set_minimum_password_length
      # respond_with resource
    end
  end

end
