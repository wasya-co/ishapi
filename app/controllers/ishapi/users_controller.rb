
##
## Cannot move this class right now - it gets hit verifying user's account, every time.
## @TODO: merge with user_profiles_controller. _vp_ 2022-10-13
##
class ::Ishapi::UsersController < Ishapi::ApplicationController

  skip_authorization_check only: %i| create fb_sign_in login |

  before_action :check_profile!, only: %i| account |

  def account
    authorize! :show, @current_profile
    render 'ishapi/user_profiles/account'
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
      render 'ishapi/user_profiles/login'
    else
      render json: {
        messages: @user.errors.messages.merge( @profile.errors.messages ),
      }, status: 400
    end
  end

  def fb_sign_in
    authorize! :fb_sign_in, Ishapi
    render 'ishapi/user_profiles/show'
  end

end
