require_dependency "ishapi/application_controller"

module Ishapi
  class UsersController < ApplicationController
    before_action :set_profile, :only => [ :fb_sign_in, :show ]

    skip_authorization_check only: %i| login |

    def fb_sign_in
      authorize! :fb_sign_in, Ishapi
      # render :json => { :status => :ok }
      render :action => 'show'
    end

    def show
      authorize! :fb_sign_in, Ishapi
    end

    def login
      @current_user = User.where( email: params[:email] ).first
      if !@current_user
        render json: { status: :not_ok }, status: 401
        return
      end
      if @current_user.valid_password?(params[:password])
        # from: application_controller#long_term_token

        # send the jwt to client
        @jwt_token = encode(user_id: @current_user.id.to_s)

        # @profile = @current_user.profile
        # render 'ishapi/users/account'

        render json: {
          email: @current_user.email,
          jwt_token: @jwt_token,
          n_unlocks: @current_user.profile.n_unlocks,
        }
      end
    end

  end
end
