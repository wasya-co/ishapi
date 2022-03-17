require_dependency "ishapi/application_controller"

module Ishapi
  class CitiesController < Ishapi::ApplicationController
    protect_from_forgery :prepend => true, :with => :exception
    layout :false

    check_authorization
    skip_before_action :verify_authenticity_token
    before_action :set_current_ability

    def index
      authorize! :index, City
      @cities = City.all
    end

    def features
      authorize! :index, City
      @cities = City.where( :is_feature => true )
    end

    def show
      @city = City.find_by :cityname => params[:cityname]
      authorize! :show, @city
    end


    private

    def set_current_ability
      @current_ability ||= ::Ishapi::Ability.new( User.new )
    end

  end
end
