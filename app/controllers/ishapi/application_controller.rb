
class ::Ishapi::ApplicationController < ActionController::Base

  def exception
    throw "this exception: #{Time.now}"
  end

  def home
    render json: { status: :ok }, status: :ok
  end

  ## POST /api/users/long_term_token , a FB login flow
  ## 2023-03-29 _vp_ This should not work, needs to be rewritten.
  def long_term_token
    accessToken   = request.headers[:accessToken]
    accessToken ||= params[:accessToken]

    params['domain'] = 'tgm.piousbox.com'

    response = ::HTTParty.get "https://graph.facebook.com/v5.0/oauth/access_token?grant_type=fb_exchange_token&" +
      "client_id=#{::FB[params['domain']][:app]}&client_secret=#{::FB[params['domain']][:secret]}&" +
      "fb_exchange_token=#{accessToken}"
    j = JSON.parse response.body
    @long_term_token  = j['access_token']
    @graph            = Koala::Facebook::API.new( accessToken )
    @me               = @graph.get_object( 'me', :fields => 'email' )
    @current_user     = User.where( :email => @me['email'] ).first
    @current_profile  = Ish::UserProfile.find_by( email: @current_user.email )

    # send the jwt to client
    @jwt_token = encode(user_profile_id: @current_user.profile.id.to_s)

    render json: {
      email: @current_user.email,
      jwt_token: @jwt_token,
      long_term_token: @long_term_token,
      n_unlocks: @current_profile.n_unlocks,
    }
  end

  ## @TODO: implement completely! _vp_ 2022-08-24
  def vote

    votee = params[:votee_class_name].constantize.find(params[:votee_id])

    authorize! :open_permission, Ishapi # @TODO: make this more rigid

    out = votee.vote(voter_id: params[:voter_id], value: params[:value].to_sym)

    if out
      render json: {
        status: 'ok',
      }
    else
      render json: {
        status: 'not_ok',
        message: votee.errors.full_messages.join(', '),
      }
    end

  end

  private

  ## This returns an empty profile if not logged in
  def check_profile
    begin
      decoded = decode(params[:jwt_token])
      @current_profile = Ish::UserProfile.find decoded['user_profile_id']
    rescue JWT::ExpiredSignature, JWT::DecodeError => e
      flash[:notice] = 'You are not logged in, or you have been logged out.'
      @current_profile = Ish::UserProfile.new
    end
  end

  ## If not logged in, errors out
  def check_profile!
    begin
      decoded = decode(params[:jwt_token])
      @current_profile = Ish::UserProfile.find decoded['user_profile_id']
    rescue JWT::ExpiredSignature, JWT::DecodeError => e
      flash[:notice] = 'You are not logged in, or you have been logged out.'
    end
  end

  # jwt
  def check_jwt
    begin
      decoded = decode(params[:jwt_token])
      @current_profile = Ish::UserProfile.find decoded['user_profile_id']
    rescue JWT::ExpiredSignature
      Rails.logger.info("JWT::ExpiredSignature")
    rescue JWT::DecodeError
      Rails.logger.info("JWT::DecodeError")
    end
    current_ability
  end

  # jwt
  def decode(token)
    decoded = JWT.decode(token, Rails.application.secrets.secret_key_base.to_s)[0]
    HashWithIndifferentAccess.new decoded
  end

  # jwt
  def encode(payload, exp = 48.hours.from_now) # @TODO: definitely change, right now I expire once in 2 days.
    payload[:exp] = exp.to_i
    JWT.encode(payload, Rails.application.secrets.secret_key_base.to_s)
  end

  def current_ability
    @current_ability ||= Ishapi::Ability.new( @current_profile )
  end

end

