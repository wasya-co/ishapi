require_dependency "ishapi/application_controller"
module Ishapi
  class VideosController < ApplicationController

    def show
      @video = Video.unscoped.find_by :slug => params[:slug]
      authorize! :show, @video
    end

    def index
      authorize! :index, Video
      @videos = Video.all
      if params[:cityname]
        city = City.find_by :cityname => params[:cityname]
        @videos = @videos.where( :city_id => city.id )
      end
      if params[:domain]
        site = Site.find_by :domain => params[:domain], :lang => :en
        @videos = @videos.where( :site_id => site.id )
      end

      @videos = @videos.page( params[:videos_page] ).per( 10 )
    end

  end
end
