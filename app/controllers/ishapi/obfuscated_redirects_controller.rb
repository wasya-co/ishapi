require_dependency "ishapi/application_controller"

module Ishapi
  class ObfuscatedRedirectsController < ApplicationController

    def show
      @obf = Office::ObfuscatedRedirect.find params[:id]
      puts! @obf, '@obf'
      authorize! :show, @obf

      visit_time = Time.now
      @obf.update_attributes({
        visited_at: visit_time,
        visits: @obf.visits + [ visit_time ],
      })

      if Rails.application.config.debug
        render and return
      end

      redirect_to @obf.to

    end

  end
end

