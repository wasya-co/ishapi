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

    ## Hmm with austin -> wasya_co , neither config nor labels can be used from parent.
    # if @map.parent_slug.present?
    #   json.config JSON.parse @map.parent.config
    #   json.labels JSON.parse @map.parent.labels
    # else
    ## I removed json parsing from here! _vp_ 2021-10-14
    ## I added json parsing here! _vo_ 2021-10-19
    json.config JSON.parse @map.config
    json.labels JSON.parse @map.labels

    json.partial! 'ishapi/markers/index', map: @map

    if @newsitems
      json.partial! 'ishapi/newsitems/index', :newsitems => @newsitems
    end

    if @galleries
      json.partial! 'ishapi/galleries/index', galleries: @galleries
    end

  end
end


