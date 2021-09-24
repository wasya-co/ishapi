#
# ishapi / maps / _show
#

this_key = [ map, params.permit! ]
json.cache! this_key do
  json.map do
    json.id          map.id.to_s
    json.slug        map.slug
    json.parent_slug map.parent_slug
    json.description map.description
    json.w           map.w
    json.h           map.h
    json.img_path    map.image.image.url(:original)
    json.updated_at  map.updated_at

    json.partial! 'ishapi/markers/index', map: map

  end
end


