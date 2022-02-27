#
# ishapi / maps / show
#

this_key = [
  @map.id, @map.updated_at,
  current_user&.profile&.updated_at,
  params.permit!
]
json.cache! this_key do
  json.map do
    json.id          @map.id.to_s
    json.slug        @map.slug
    json.parent_slug @map.parent_slug
    json.description @map.description
    json.w           @map.w
    json.h           @map.h
    json.img_path    @map.image ? @map.image.image.url(:original) : image_missing
    json.updated_at  @map.updated_at
    json.rated       @map.rated

    if @map.is_premium
      json.premium_tier @map.premium_tier
      json.is_premium   @map.premium_tier > 0
      json.is_purchased current_user&.profile&.has_premium_purchase( @map )
    end

    if @map.map
      json.partial! 'ishapi/maps/show', map: @map.map
      json.config JSON.parse @map.parent.config
      json.labels JSON.parse @map.parent.labels
      json.partial! 'ishapi/markers/index', markers: @markers
    else
      ## I removed json parsing from here! _vp_ 2021-10-14
      ## I added json parsing here, and is seems right. _vp_ 2021-10-19
      json.config JSON.parse @map.config
      json.labels JSON.parse @map.labels
      json.partial! 'ishapi/markers/index', markers: @markers
    end

    json.breadcrumbs do
      json.array! @map.breadcrumbs do |b|
        json.name b[:name]
        json.slug b[:slug]
        json.link b[:link]
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


