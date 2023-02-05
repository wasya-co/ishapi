require_dependency "ishapi/application_controller"

module Ishapi
  class OptionPriceItemsController < ApplicationController

    # before_action :soft_check_long_term_token, only: [ :show ]
    # before_action :check_jwt

    ## params: symbol, begin_at, end_at
    def view
      authorize! :view_chain, ::IronWarbler::OptionPriceItem.new
      @opis = ::IronWarbler::OptionPriceItem.where({ ticker: params[:symbol]
      }).where( "timestamp BETWEEN ? and ? ", params[:begin_at], params[:end_at]
      ).limit(100)
    end

    def view_by_symbol
      authorize! :view_chain, ::IronWarbler::OptionPriceItem.new
      @opis = ::IronWarbler::OptionPriceItem.where({ symbol: params[:symbol]
      }).limit(100)
      render 'view'
    end

  end
end
