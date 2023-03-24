
require_dependency "ishapi/application_controller"

##
## supersedes Ishapi::MapsController
##
class Ishapi::LocationsController < Ishapi::ApplicationController

  before_action :check_profile # , only: [ :show, :show_marker ]

  def show
    if 'self' == params[:slug] # @TODO: constantize _vp_ 2023-01-11
      @location = ::Gameui::Map.where( slug: @current_profile[:email] ).first
    else
      @location   = ::Gameui::Map.where( slug: params[:slug] ).first
      @location ||= ::Gameui::Map.find params[:slug]
    end

    authorize! :show, @location
    map = @location.map || @location # @TODO: remove _vp_ 2023-03-20

    @newsitems = @location.newsitems.page( params[:newsitems_page]
      ).per( @location.newsitems_page_size )

    @markers = map.markers.permitted_to(@current_profile).order_by(ordering: :asc)
    # case map.ordering_type
    # when ::Gameui::Map::ORDERING_TYPE_ALPHABETIC
    #   @markers = @markers.order_by( name: :asc )
    # when ::Gameui::Map::ORDERING_TYPE_CUSTOM
    #   @markers = @markers.order_by( ordering: :asc )
    # end

    if map.is_premium && !@current_profile.has_premium_purchase( map )
      render 'show_restricted'
    else
      respond_to do |format|
        format.json do
          render 'show'
        end
        format.html do
          render 'show'
        end
      end
    end
  end

  def show_marker
    @marker = ::Gameui::Marker.find_by slug: params[:slug]
    authorize! :show, @marker
    render json: @marker
  end

end

