
#
# ishapi / galleries / index
#

json.array! @galleries do |gallery|
  json.id          gallery.id.to_s
  json.name        gallery.name
  json.slug gallery.galleryname
  json.slug        gallery.slug
  json.subhead     gallery.subhead
  json.username    gallery.user_profile.name
  json.cityname    gallery.city.name    if gallery.city
  json.tag_names   gallery.tags.map &:slug
  json.venuename   gallery.venue.name   if gallery.venue
  json.partial! 'ishapi/photos/index', :photos => gallery.photos
end

