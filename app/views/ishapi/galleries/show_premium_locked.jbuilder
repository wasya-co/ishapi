#
# ishapi / galleries / show_premium_locked
#

this_key = [ @gallery, params.permit! ]
json.cache! this_key do
  json.gallery do

    json.id           @gallery.id.to_s
    json.premium_tier @gallery.premium_tier
    json.is_premium   @gallery.is_premium
    json.is_purchased false

    # json.partial! 'ishapi/galleries/show', gallery: @gallery
    # json.partial! 'ishapi/photos/index', :photos => [ @gallery.photos[0] ]
  end
  json.message      "This is premium content - please purchase it to view!"
end

