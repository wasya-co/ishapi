#
# ishapi / maps / _show
#

## @TODO: make sure that _show.jbuilder and show.jbuilder are reasonably deduped

this_key = [ map.id, map.updated_at, params.permit! ]
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
    json.rated       map.rated

    json.partial! 'ishapi/markers/index', map: map

    ## I removed json parsing from here! _vp_ 2021-10-14
    ## I added json parsing here! _vo_ 2021-10-19
    if map.parent_slug.present?
      json.config JSON.parse @map.parent.config
      json.labels JSON.parse @map.parent.labels
    else
      json.config JSON.parse @map.config
      json.labels JSON.parse @map.labels
    end

  end
end


