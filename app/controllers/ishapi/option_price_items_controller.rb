require_dependency "ishapi/application_controller"

module Ishapi
  class OptionPriceItemsController < ApplicationController

    # before_action :soft_check_long_term_token, only: [ :show ]
    # before_action :check_jwt

    ## params: symbol, begin_at, end_at
    def view
      authorize! :view_chain, ::Iro::OptionPriceItem.new
      @opis = ::Iro::OptionPriceItem.where({ ticker: params[:symbol]
      }).where( "timestamp BETWEEN ? and ? ", params[:begin_at], params[:end_at]
      ).limit(100)
    end

    def view_by_symbol
      authorize! :view_chain, ::Iro::OptionPriceItem.new
      @opis = ::Iro::OptionPriceItem.where({ symbol: params[:symbol]
      }).limit(100)
      render 'view'
    end

  end
end

=begin

SELECT symbol, bid, ask, MAX(`timestamp`) as a
FROM iwa_option_price_items
where symbol = "GME_021023P20"
GROUP BY symbol, bid, ask, DATE(`timestamp`), HOUR(`timestamp`), Minute(`timestamp`)
order by a desc;

SELECT symbol, MAX(`timestamp`) as a
FROM iwa_option_price_items
where symbol = "GME_021023P20"
GROUP BY symbol, DATE(`timestamp`), HOUR(`timestamp`), Minute(`timestamp`)
order by a desc;

select timestamp as a FROM iwa_option_price_items
where symbol = "GME_021023P20"
order by a desc;

=end


