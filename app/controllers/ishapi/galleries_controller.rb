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
      @gallery = ::Gallery.unscoped.where( slug: params[:slug] ).first
      @gallery ||= ::Gallery.unscoped.where( id: params[:slug] ).first
      authorize! :show, @gallery

      @photos = @gallery.photos.order_by( ordering: :asc )
      respond_to do |format|
        format.json do

          if @gallery.is_premium
            if @current_user&.profile&.has_premium_purchase( @gallery )
              render 'show_premium_unlocked'
            else
              render 'show_premium_locked'
            end
          else
            render 'show'
          end

        end
        format.html do

          if @gallery.is_premium
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

  end
end
