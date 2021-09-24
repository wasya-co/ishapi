#
# ishapi / maps / show
#

this_key = [ @map, params.permit! ]
json.cache! this_key do
  json.map do
    json.id          @map.id.to_s
    json.slug        @map.slug
    json.parent_slug @map.parent_slug
    json.description @map.description
    json.w           @map.w
    json.h           @map.h
    json.img_path    @map.image.image.url(:original)
    json.updated_at  @map.updated_at

    if @map.map
      json.partial! 'ishapi/maps/show', map: @map.map
    end

    json.breadcrumbs do
      json.array! @map.breadcrumbs do |b|
        json.name b[:name]
        json.slug b[:slug]
        json.link b[:link]
      end
    end

    json.partial! 'ishapi/markers/index', map: @map

    if @newsitems
      json.partial! 'ishapi/newsitems/index', :newsitems => @newsitems
    end

    if @galleries
      json.partial! 'ishapi/galleries/index', galleries: @galleries
    end

  end
end


