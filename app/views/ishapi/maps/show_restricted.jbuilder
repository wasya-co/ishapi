#
# ishapi / maps / show_restricted
#
map = @map

this_key = [ map.id, map.updated_at ]
json.cache! this_key do

  json.map do
    json.id           map.id.to_s
    json.slug         map.slug
    json.parent_slug  map.parent_slug
    json.updated_at   map.updated_at
    json.rated        map.rated
    json.name         map.name
    json.premium_tier map.premium_tier
    json.is_premium   map.is_premium

    json.breadcrumbs do
      json.array! map.breadcrumbs do |b|
        json.name b[:name]
        json.slug b[:slug]
        json.link b[:link]
      end
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

    # json.map({ config: {} })

  end
end


