module Ishapi
  class ApplicationController < ActionController::Base

    ## POST /api/users/long_term_token , a FB login flow
    def long_term_token
      accessToken   = request.headers[:accessToken]
      accessToken ||= params[:accessToken]

      params['domain'] = 'tgm.piousbox.com'

      response = ::HTTParty.get "https://graph.facebook.com/v5.0/oauth/access_token?grant_type=fb_exchange_token&" +
        "client_id=#{FB[params['domain']][:app]}&client_secret=#{FB[params['domain']][:secret]}&" +
        "fb_exchange_token=#{accessToken}"
      j = JSON.parse response.body
      @long_term_token  = j['access_token']
      @graph            = Koala::Facebook::API.new( accessToken )
      @me               = @graph.get_object( 'me', :fields => 'email' )
      @current_user     = User.where( :email => @me['email'] ).first

      # send the jwt to client
      @jwt_token = encode(user_id: @current_user.id.to_s)

      render json: {
        email: @current_user.email,
        jwt_token: @jwt_token,
        long_term_token: @long_term_token,
        n_unlocks: @current_user.profile.n_unlocks,
      }
    end

    private

    def check_profile
      begin
        decoded = decode(params[:jwt_token])
        @current_user = User.find decoded['user_id']
      rescue JWT::ExpiredSignature => e
        puts! e, 'ee1'
        flash[:notice] = 'You arent logged in, or you have been logged out.'
        @current_user = User.new
      end
    end

    # jwt
    def check_jwt
      begin
        decoded = decode(params[:jwt_token])
        @current_user = User.find decoded['user_id']
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
    def encode(payload, exp = 2.hours.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, Rails.application.secrets.secret_key_base.to_s)
    end

    def current_ability
      @current_ability ||= Ishapi::Ability.new( current_user )
    end

  end
end
