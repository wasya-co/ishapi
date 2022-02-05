
require_dependency "ishapi/application_controller"

class Ishapi::MapsController < Ishapi::ApplicationController
  before_action :check_profile, only: [ :show ]

  def show
    byebug
    @location = ::Gameui::Map.unscoped.find_by slug: params[:slug]
    @map = @location.map || @location
    authorize! :show, @map
    @newsitems = @location.newsitems

    ##
    ## @TODO: absolutely change this!
    ##

    @markers = @map.markers.where( is_active: true )
    if @current_user
      a = @current_user.profile.shared_markers.unscoped.where( is_active: true, map_id: @map.id ).to_a
      @markers = @markers + a
    end

    # case @map.ordering_type
    # when ::Gameui::Map::ORDERING_TYPE_ALPHABETIC
    #   @markers = @markers.order_by( name: :asc )
    # when ::Gameui::Map::ORDERING_TYPE_CUSTOM
    #   @markers = @markers.order_by( ordering: :asc )
    # end

    # ## @TODO: figure this out eventually
    # if city = City.where( cityname: @map.slug ).first
    #   # @newsitems = city.newsitems
    #   @galleries = city.galleries
    #   @reports = city.reports
    #   @videos = city.videos
    # end

  end

  def show_marker
    @marker = ::Gameui::Marker.find_by slug: params[:slug]
    authorize! :show, @marker
    render json: @marker
  end

end

