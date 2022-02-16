require_dependency "ishapi/application_controller"
module Ishapi
  class StockWatchesController < ApplicationController

    before_action :check_jwt

    def index
      authorize! :index, IronWarbler::StockWatch
      @stock_watches = IronWarbler::StockWatch.active # @TODO: restrict by-profile, no?
    end

  end
end
