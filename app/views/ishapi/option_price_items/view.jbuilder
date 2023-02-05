#
# ishapi / option_price_items / view
#


json.array! @opis do |opi|
  json.ticker     opi.ticker
  # json.putCall    opi.putCall
  json.symbol     opi.symbol
  json.bid        opi.bid
  json.ask        opi.ask
  json.last       opi.last
  # json.lastPrice  opi.lastPrice
  # json.open opi.openPrice
  json.timestamp opi.timestamp
end

