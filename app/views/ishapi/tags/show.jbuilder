
#
# _vp_ 20180204
# ishapi / tags / show
#

json.name @tag.name
json.slug @tag.slug

json.partial! 'ishapi/features/index',  :features  => @tag.features, :resource => @tag
json.partial! 'ishapi/newsitems/index', :newsitems => @tag.newsitems.page( params[:newsitems_page] ).per( params[:newsitems_per] || 25 )
json.partial! 'ishapi/reports/index',   :reports   => @tag.reports.page( params[:reports_page]     ).per( params[:reports_per] || 25 )
json.partial! 'ishapi/galleries/index', :galleries => @tag.galleries.page( params[:galleries_page] ).per( params[:galleries_per] || 25 )
json.partial! 'ishapi/videos/index',    :videos    => @tag.videos.page( params[:videos_page]       ).per( params[:videos_per] || 25 )
