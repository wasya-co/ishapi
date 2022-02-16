require_dependency "ishapi/application_controller"

module Ishapi
  class UsersController < ApplicationController

    skip_authorization_check only: %i| fb_sign_in login |

    before_action :check_profile_hard, only: %i| account |

    def account
      @profile = current_user&.profile
      authorize! :show, @profile
      render 'ishapi/users/account'
    rescue CanCan::AccessDenied
      render json: {
        status: :not_ok,
      }, status: 401
    end

    def fb_sign_in
      authorize! :fb_sign_in, Ishapi
      # render :json => { :status => :ok }
      render :action => 'show'
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
        @profile = @current_user.profile

=begin
        render json: {
          email: @current_user.email,
          jwt_token: @jwt_token,
          n_unlocks: @current_user.profile.n_unlocks,
        }
=end

      end
    end

  end
end
