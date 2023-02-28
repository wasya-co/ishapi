
require_dependency "ishapi/application_controller"
module Ishapi
  class LeadsetsController < ApplicationController


    def destroy
      puts! params, 'params'

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

