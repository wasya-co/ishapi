#
# ishapi / markers / _index
#

json.markers do
  json.array! markers do |marker|
    json.name marker.name
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
    json.asset3d_path   marker.asset3d ? marker.asset3d.object.url : ''

    ## @TODO: this is copy-pasted and should be abstracted.
    if destination = marker.destination
      json.destination_slug destination.slug # @TODO: this looks obsolete, if I'm using slug instead. _vp_ 2022-09-23
      json.slug             destination.slug
      json.premium_tier     destination.premium_tier
      json.is_premium       destination.is_premium
      json.id               destination.id.to_s
      if destination.is_premium
        if current_profile
          json.is_purchased current_profile.has_premium_purchase( destination )
        end
      end
    end

  end
end
