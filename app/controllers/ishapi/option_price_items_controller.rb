require_dependency "ishapi/application_controller"

module Ishapi
  class OptionPriceItemsController < ApplicationController

    # before_action :soft_check_long_term_token, only: [ :show ]
    # before_action :check_jwt

    ## params: symbol, begin_at, end_at
    def view
      authorize! :view_chain, ::Iro::OptionPriceItem
      @opis = ::Iro::OptionPriceItem.where({ ticker: params[:symbol]
      }).where( "timestamp BETWEEN ? and ? ", params[:begin_at], params[:end_at]
      ).limit(100)
    end

    def view_by_symbol
      authorize! :view_chain, ::Iro::OptionPriceItem
      @opis = ::Iro::OptionPriceItem.where({ symbol: params[:symbol]
      }).limit(100)
      render 'view'
    end

    # kind-1, always
    def index
      authorize! :view_chain, ::Iro::OptionPriceItem
      @opis = Iro::OptionPriceItem.where({
        expirationDate: '1676062800000',
        timestamp: '2023-02-06 14:46:48',
      })
      @outs = {}
      @opis.map do |opi|
        r = @outs[opi.strikePrice] || {}
        r[opi.putCall] = ((opi.bid + opi.ask)/2).round(3)
        @outs[opi.strikePrice] = r
      end
      render json: @outs
      return
    end

  end
end


