require_dependency "ishapi/application_controller"

module Ishapi
  class LeadActionsController < ApplicationController

    def create
      if !params[:lead_id]
        render json: { status: :ok }
        return
      end
      tmpl = Office::LeadActionTemplate.find( params[:tmpl_id] )
      puts! tmpl, 'tmpl'
      lead_action = Office::LeadAction.find_or_create_by({
        lead_id: params[:lead_id],
        tmpl_id: params[:tmpl_id],
      })
      lead_action.params = params.to_json
      lead_action.save
      render json: { status: :ok, message: 'saved' }
    end

  end
end
