
#
# ishapi / cities / features
#

key = [ ::Ish::CacheKey.one.feature_cities ]
json.cache! key do
  json.partial! 'index', :cities => @cities
end
