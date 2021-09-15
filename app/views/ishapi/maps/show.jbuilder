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
    json.img_path    @map.img_path
    json.updated_at  @map.updated_at

    json.breadcrumbs do
      json.array! @map.breadcrumbs do |b|
        json.name b[:name]
        json.slug b[:slug]
        json.link b[:link]
      end
    end

    json.markers do
      json.array! @markers do |marker|
        json.name marker.name
        json.slug marker.slug
        json.x    marker.x
        json.y    marker.y
        json.w    marker.w
        json.h    marker.h
        json.img_path marker.img_path
        json.title_img_path marker.title_img_path
        json.item_type marker.item_type
      end
    end

    if @newsitems
      json.partial! 'ishapi/newsitems/index', :newsitems => @newsitems
    end

    if @galleries
      json.partial! 'ishapi/galleries/index', galleries: @galleries
    end

  end
end


