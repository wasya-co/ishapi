#
# ishapi / maps / _show
#

this_key = [ map.id, map.updated_at ]
json.cache! this_key do

  json.map do
    json.id           map.id.to_s
    json.slug         map.slug
    json.parent_slug  map.parent_slug
    json.description  map.description
    json.w            map.w
    json.h            map.h
    # json.x            map.x
    # json.y            map.y
    # json.map_type     map.map_type
    json.img_path     map.image.image.url(:original)
    json.updated_at   map.updated_at
    json.rated        map.rated
    json.name         map.name

    json.premium_tier map.premium_tier
    json.is_premium   map.is_premium
    json.is_purchased current_profile&.has_premium_purchase( map )

    json.breadcrumbs do
      json.array! map.breadcrumbs do |b|
        json.name b[:name]
        json.slug b[:slug]
        json.link b[:link]
      end
    end

    if markers
      json.partial! 'ishapi/markers/index', markers: markers
    end

    if newsitems
      json.partial! 'ishapi/newsitems/index', newsitems: newsitems
    end

    if tags
      json.partial! 'ishapi/tags/index', tags: tags
    end

    if map.map
      json.partial! 'ishapi/maps/show', map: map.map
    end

    ## _vp_ 2021-10-14 I removed json parsing from here!
    ## _vp_ 2021-10-19 I added json parsing here!
    ## _vp_ 2022-09-13 Must use my own config, example: 3D -> geodesic. Parent is MapPanelNoZoom, but self is ThreePanelV1
    ##                 Maybe it's if map_slug is present, rather than parent_slug?
    if map.map_slug.present?
      json.config JSON.parse map.map.config
      json.labels JSON.parse map.map.labels
    else
      json.config JSON.parse map.config
      json.labels JSON.parse map.labels
    end

  end
end


