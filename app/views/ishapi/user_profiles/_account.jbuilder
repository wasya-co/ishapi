
json.id                profile.id.to_s
json.name              profile.name
json.email             profile.email
json.profile_photo_url profile.profile_photo.photo.url( :thumb ) if profile.profile_photo

json.n_reports     profile.reports.count
json.n_galleries   profile.galleries.count
json.n_videos      profile.videos.count

json.n_unlocks     profile.n_unlocks # @TODO: which one is deprecated?
json.is_purchasing profile.is_purchasing

# json.bookmarks profile.bookmarks do |b|
#   json.name b.name
#   json.slug b.slug
# end

