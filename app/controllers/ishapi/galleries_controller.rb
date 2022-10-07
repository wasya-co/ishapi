require_dependency "ishapi/application_controller"

module Ishapi
  class GalleriesController < ApplicationController

    # before_action :soft_check_long_term_token, only: [ :show ]
    before_action :check_jwt

    def index
      @galleries = Gallery.all
      authorize! :index, Gallery
      if params[:domain]
        @site = Site.find_by( :domain => params[:domain], :lang => 'en' )
        @galleries = @galleries.where( :site => @site )
      end
      @galleries = @galleries.page( params[:galleries_page] ).per( 10 )
    end

    def show
      @gallery = ::Gallery.unscoped.find_by :slug => params[:slug]
      authorize! :show, @gallery
      if @gallery.premium?
        if @current_user&.profile&.has_premium_purchase( @gallery )
          render 'show_premium_unlocked'
        else
          render 'show_premium_locked'
        end
      else
        render 'show'
      end
    end

  end
end
