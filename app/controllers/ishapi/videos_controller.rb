require_dependency "ishapi/application_controller"
module Ishapi
  class VideosController < ApplicationController

    def show
      @video = Video.unscoped.find_by :slug => params[:slug]
      authorize! :show, @video
    end

    def index
      authorize! :index, Video
      @videos = Video.all.published
      @videos = @videos.page( params[:videos_page] ).per( 10 )
    end

  end
end
