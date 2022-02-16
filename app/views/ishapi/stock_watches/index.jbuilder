
#
# ishapi / stock_watches / index
#

json.array! @stock_watches do |w|
  json.i w
  json.price w[:price]
  json.ticker w[:ticker]
end

