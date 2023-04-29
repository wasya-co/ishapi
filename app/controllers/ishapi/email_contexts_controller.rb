
require_dependency "ishapi/application_controller"

# gem_dir = Gem::Specification.find_by_name("ish_models").gem_dir
# require "#{gem_dir}/lib/office/email_conversation"

module Ishapi
  class EmailContextsController < ApplicationController

    before_action :check_jwt

    def summary
      authorize! :summary, Ish::EmailContext
      @results = Ish::EmailContext.summary

      respond_to do |format|
        format.html
        format.csv do
          render layout: false
        end
        format.json do
          render json: @results
        end
      end
    end

  end
end
