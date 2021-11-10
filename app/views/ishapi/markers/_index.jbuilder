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
    json.img_path       marker.image.image.url(:original)
    json.title_img_path marker.title_image.image.url(:thumb)
    json.item_type      marker.item_type
    json.url            marker.url
  end
end
