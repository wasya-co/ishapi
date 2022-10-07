
require_dependency "ishapi/application_controller"

class Ishapi::MapsController < Ishapi::ApplicationController
  before_action :check_profile, only: [ :show ]

  def show
    @location   = ::Gameui::Map.where( slug: params[:slug] ).first
    @location ||= ::Gameui::Map.find params[:slug]
    @map = @location.map || @location

    authorize! :show, @map

    @newsitems = @location.newsitems.page( params[:newsitems_page]
      ).per( @location.newsitems_page_size )

    @markers = @map.markers.permitted_to(@current_profile).order_by(ordering: :asc)
    # case @map.ordering_type
    # when ::Gameui::Map::ORDERING_TYPE_ALPHABETIC
    #   @markers = @markers.order_by( name: :asc )
    # when ::Gameui::Map::ORDERING_TYPE_CUSTOM
    #   @markers = @markers.order_by( ordering: :asc )
    # end

    if @map.is_premium && !@current_profile.has_premium_purchase( @map )
      render 'show_restricted'
    else
      render 'show'
    end
  end

  def show_marker
    @marker = ::Gameui::Marker.find_by slug: params[:slug]
    authorize! :show, @marker
    render json: @marker
  end

end

