
#
# ishapi / reports / show
#

params.permit!
key = [ @report, params ]
json.cache! key do
  json.report do
    json.id          @report.id.to_s
    json.item_type   @report.class.name
    json.name        @report.name
    json.reportname  @report.slug # @TODO: @deprecated, remove
    json.slug        @report.slug
    if @report.photo
      json.photo_url   @report.photo.photo.url( :small )
      json.thumb_url   @report.photo.photo.url( :thumb )
    end

    # @TODO: move this to meta
    json.created_at  @report.created_at
    json.updated_at  @report.updated_at
    json.username    @report.user_profile.name if @report.user_profile
    json.cityname    @report.city.cityname if @report.city
    json.subhead     @report.subhead

    case @report.item_type
    when 'wordpress'
      json.raw_json    JSON.parse(@report.raw_json)
    else
      json.description @report.descr
    end

    if @report.photo
      json.photo do
        json.thumb_url @report.photo.photo.url :thumb
        json.small_url @report.photo.photo.url :small
        json.large_url @report.photo.photo.url :large
      end
    end

    json.partial! 'ishapi/tags/index',   :tags   => @report.tags
  end

  # @deprecated, but specs use this _vp_ 20180423
  if @report.photo
    json.photo do
      json.thumb_url @report.photo.photo.url :thumb
      json.small_url @report.photo.photo.url :small
      json.large_url @report.photo.photo.url :large
    end
  end

end
