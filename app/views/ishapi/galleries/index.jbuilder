
#
# ishapi / galleries / index
#

json.array! @galleries do |gallery|
  json.id          gallery.id.to_s
  json.name        gallery.name
  json.slug        gallery.slug
  json.slug        gallery.slug
  json.subhead     gallery.subhead
  json.username    gallery.user_profile.name
  json.partial! 'ishapi/photos/index', :photos => gallery.photos
end

