#
# ishapi / galleries / _show
#

# @TODO: remove this file, this looks like a newsitem

json.id           gallery.id.to_s
json.item_type    gallery.class.name
json.name         gallery.name
json.slug  gallery.slug
json.description  gallery.description
json.username     gallery.username || 'piousbox'
json.n_photos     gallery.photos.length
json.slug         gallery.slug
json.subhead      gallery.subhead
json.partial!    'ishapi/application/meta', :item => gallery
if gallery.is_premium
  json.premium_tier gallery.premium_tier
  json.is_premium   gallery.premium_tier > 0
  json.is_purchased @current_profile&.has_premium_purchase( gallery )
  json.partial!    'ishapi/photos/index',     :photos => [ gallery.photos[0] ]
else
  json.partial!    'ishapi/photos/index',     :photos => gallery.photos
end
