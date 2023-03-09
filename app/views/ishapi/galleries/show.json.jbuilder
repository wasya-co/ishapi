#
# ishapi / galleries / show
#

this_key = [ @gallery, params.permit! ]
json.cache! this_key do
  json.gallery do
    json.partial! 'ishapi/application/meta', item: @gallery
    json.partial! 'ishapi/galleries/show', gallery: @gallery, photos: @photos
  end
end

