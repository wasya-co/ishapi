require_dependency "ishapi/application_controller"

module ::Ishapi
  class EmailUnsubscribesController < ApplicationController

    layout false

    def create
      authorize! :open_permission, ::Ishapi
      @lead = Lead.find params[:lead_id]

      if( !params[:token] ||
          @lead.unsubscribe_token != params[:token] )
        render code: 400, message: "We're sorry, but something went wrong. Please try again later."
        return
      end

      @unsubscribe = ::Ish::EmailUnsubscribe.find_or_create_by({
        lead_id:     params[:lead_id],
        template_id: params[:template_id],
        campaign_id: params[:campaign_id],
      })
      flag = @unsubscribe.update_attributes({
        unsubscribed_at: Time.now,
      })
      if flag
        flash_notice "You have been unsubscribed."
      else
        flash_alert "We're sorry, but something went wrong. Please try again later."
      end

    end
  end

end
