
require_dependency "ishapi/application_controller"
module Ishapi
  class LeadsController < ApplicationController

    before_action :check_jwt

    def index
      authorize! :leads_index, ::Ishapi
      out = Lead.all.page( params[:leads_page] ).per( @current_profile.per_page )
      render json: {
        items: out,
      }
    end

  end
end

