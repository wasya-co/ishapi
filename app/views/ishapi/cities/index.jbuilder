
#
# ishapi / cities / index
#

key = [ ::Ish::CacheKey.one.cities ]
json.cache! key do
  json.partial! 'index', :cities => @cities
end
