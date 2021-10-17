require_dependency "ishapi/application_controller"
module Ishapi
  class VenuesController < ApplicationController

    def index
      authorize! :index, ::Venue
      @venues = ::Venue.all
      if params[:cityname]
        city = City.find_by :cityname => params[:cityname]
        @venues = @venues.where( :city => city )
      end
    end

    def show
      @venue = Venue.find_by :slug => params[:venuename]
      authorize! :show, @venue
    end

  end
end
