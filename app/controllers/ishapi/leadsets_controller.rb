
require_dependency "ishapi/application_controller"
module Ishapi
  class LeadsetsController < ApplicationController

    load_and_authorize_resource

    def destroy
      authorize! :leadsets_destroy, ::Ishapi

      leadsets = Leadset.find( params[:leadset_ids] )
      @results = []
      leadsets.each do |leadset|
        @results.push leadset.discard
      end
      flash[:notice] = "Discard outcome: #{@results.inspect}."
      redirect_to action: 'index'
    end

    def index
      authorize! :leadsets_index, ::Ishapi
      out = Leadset.all
      render json: {
        items: out,
      }
    end

  end
end

