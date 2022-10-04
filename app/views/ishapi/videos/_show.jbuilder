
#
# ish_api / videos / _show
#

json.id          video.id.to_s
json.slug        video.id.to_s
json.youtube_id  video.youtube_id
json.name        video.name
json.description video.descr
json.subhead     video.subhead
json.x           video.x
json.y           video.y
json.url         video.video.url

if video.city
  json.cityname video.city.cityname
  json.city do
    json.name video.city.name
    json.slug video.city.cityname
  end
end

json.tags         [ { slug: 'adventure', name: 'Adventure' },
                    { slug: 'bars-and-clubs', name: 'Bars & Clubs' },
                    { slug: 'food', name: 'Food' },
                    { slug: 'late-night', name: 'Late Night' } ]

if video.user_profile
  json.username video.user_profile.name
end

## @TODO: this is copy-pasted and should be abstracted.
if video.is_premium
  json.premium_tier video.premium_tier
  json.is_premium   video.premium_tier > 0
  if current_profile
    json.is_purchased current_profile.has_premium_purchase( video )
  end
end

if video.thumb
  json.photo_s169_url   video.thumb.url( :s169 )
  json.photo_thumb2_url video.thumb.url( :thumb2 )
end
