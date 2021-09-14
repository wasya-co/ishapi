
#
# ishapi / sites / show
#

key = [ @site.id, @site.updated_at, params.permit! ]
json.cache! key do
  json.id          @site.id.to_s
  json.domain      @site.domain
  json.lang        @site.lang
  json.langs       @langs
  json.title       @site.title
  json.subhead     @site.subhead
  json.description @site.description

  json.email @current_user.email

  json.is_ads_enabled         @site.is_ads_enabled
  json.play_videos_in_preview @site.play_videos_in_preview
  json.newsitems_per_page     @site.newsitems_per_page

  json.partial! 'ishapi/features/index',  :features  => @site.features, :resource => @site
  json.partial! 'ishapi/galleries/index', :galleries => @galleries,     :resource => @site
  json.partial! 'ishapi/newsitems/index', :newsitems => @newsitems,     :resource => @site
  json.partial! 'ishapi/reports/index',   :reports   => @reports,       :resource => @site
  json.partial! 'ishapi/videos/index',    :videos    => @site.videos

  json.feature_tags do
    json.array! @feature_tags do |feature_tag|
      json.partial! 'ishapi/tags/widget', :tag => feature_tag
    end
  end
end
