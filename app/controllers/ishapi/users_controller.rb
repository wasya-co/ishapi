# require_dependency "ishapi/application_controller"

module Ishapi
  class UsersController < Ishapi::ApplicationController

    skip_authorization_check only: %i| create fb_sign_in login |


    before_action :check_profile_hard, only: %i| account |

    def account
      @profile = @current_user&.profile
      authorize! :show, @profile
      render 'ishapi/users/account'
    rescue CanCan::AccessDenied
      render json: {
        status: :not_ok,
      }, status: 401
    end

    def create
      authorize! :open_permission, Ishapi
      new_user_params = params[:user].permit!

      @profile = Profile.new( email: new_user_params[:email] )
      @user = User.new( email: new_user_params[:email], password: new_user_params[:password], profile: @profile )

      if @profile.save && @user.save
        @jwt_token = encode(user_id: @user.id.to_s)
        render 'login'
      else
        render json: {
          messages: @user.errors.messages.merge( @profile.errors.messages ),
        }, status: 400
      end
    end

    def fb_sign_in
      authorize! :fb_sign_in, Ishapi
      # render :json => { :status => :ok }
      render :action => 'show'
    end

  end
end
