require_dependency "ishapi/application_controller"
module Ishapi
  class MapsController < ApplicationController

    before_action :check_profile, only: [ :show ]

    def index
      authorize! :index, ::Gameui::Map
      @maps = ::Gameui::Map.all
    end

    def show
      @map = ::Gameui::Map.find_by slug: params[:slug]
      @markers = @map.markers.where( is_active: true )
      @newsitems = @map.newsitems

      case @map.ordering_type
      when ::Gameui::Map::ORDERING_TYPE_ALPHABETIC
        @markers = @markers.order_by( name: :asc )
      when ::Gameui::Map::ORDERING_TYPE_CUSTOM
        @markers = @markers.order_by( ordering: :asc )
      end

      if city = City.where( cityname: @map.slug ).first
        @newsitems = city.newsitems
        @galleries = city.galleries
        @reports = city.reports
        @videos = city.videos
      end
      authorize! :show, @map
    end

    def show_marker
      @marker = ::Gameui::Marker.find_by slug: params[:slug]
      authorize! :show, @marker
      render json: @marker
    end

  end
end
