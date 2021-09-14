require_dependency "ishapi/application_controller"

module Ishapi
  class SitesController < ApplicationController

    # before_action :check_profile_optionally, only: %i| show |

    def index
      authorize! :index, ::Site
      @sites = ::Site.all
    end

    def show

      decoded = decode(params[:jwt_token])
      @current_user = User.find decoded['user_id']
      # sign_in @current_user, scope: :user
      # current_ability


      if params[:domain].include?(".json")
        domain = params[:domain][0...-5]
      else
        domain = params[:domain]
      end
      @site = ::Site.find_by(domain: domain, lang: :en)
      # authorize! :show, @site

      puts! @current_user, 'showz'

      if @site.is_private
        if !params[:accessToken]
          render :json => { :status => :unauthorized}, :status => :unauthorized
          return
        end
        access_token = params[:accessToken]
        @graph = Koala::Facebook::API.new( access_token, ::FB[@site.domain][:secret] )
        @profile = @graph.get_object "me", :fields => 'email'
        if @site.private_user_emails.include?( @profile['email'] )
          ;
        else
          render :json => { :status => :unauthorized}, :status => :unauthorized
          render :status => :unauthorized
          return
        end
      end

      @galleries    = @site.galleries.limit( 10 ) # @TODO: paginate
      @newsitems    = @site.newsitems.limit( @site.newsitems_per_page ) # @TODO: paginate
      @reports      = @site.reports.limit( 10 ) # @TODO: paginate
      @langs        = ::Site.where( :domain => domain ).map( &:lang )
      @feature_tags = @site.tags.where( :is_feature => true )

      puts! 'did it render?'
    end

    private

    # jwt
    def decode(token)
      decoded = JWT.decode(token, Rails.application.secrets.secret_key_base.to_s)[0]
      HashWithIndifferentAccess.new decoded
    end

  end
end
