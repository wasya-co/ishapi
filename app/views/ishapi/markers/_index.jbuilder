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

    ## @TODO: this is copy-pasted and should be abstracted.
    destination = marker.destination
    json.premium_tier destination.premium_tier
    json.is_premium   destination.is_premium
    json.id           destination.id.to_s
    if destination.is_premium
      if current_user && current_user.profile
        json.is_purchased current_user.profile.has_premium_purchase( destination )
      end
    end

  end
end
