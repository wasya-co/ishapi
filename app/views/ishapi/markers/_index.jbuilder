#
# ishapi / markers / _index
#

json.markers do
  json.array! markers do |marker|
    json.name marker.name
    json.slug marker.slug
    json.x    marker.x
    json.y    marker.y
    json.w    marker.w
    json.h    marker.h
    json.centerOffsetX  marker.centerOffsetX
    json.centerOffsetY  marker.centerOffsetY
    json.img_path       marker.image ? marker.image.image.url(:original) : image_missing
    json.title_img_path marker.title_image ? marker.title_image.image.url(:thumb) : image_missing
    json.item_type      marker.item_type
    json.url            marker.url
    json.premium_tier   marker.destination.premium_tier
    json.id             marker.destination.id.to_s
  end
end
