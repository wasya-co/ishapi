#
# ishapi / option_price_items / index
#

json.array! @outs do |out|
  json.strikePrice opi.strikePrice
  json.symbol     opi.symbol
  json.bid        opi.bid
  json.ask        opi.ask
  json.natural    ((opi.bid + opi.ask )/2).round(3)
  json.last       opi.last
  # json.lastPrice  opi.lastPrice
  # json.open opi.openPrice
  json.timestamp opi.timestamp.strftime('%H:%M:%S')
  json.seconds   opi.timestamp.to_i
end

