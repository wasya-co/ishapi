
json.id                @profile.id
json.name              @profile.name
json.email             @profile.email
json.profile_photo_url @profile.profile_photo.photo.url( :thumb ) if @profile.profile_photo

json.n_reports   @profile.reports.count
json.n_galleries @profile.galleries.count
json.n_videos    @profile.videos.count
json.n_stars     @profile.n_stars # @TODO: which one is deprecated?
json.n_unlocks   @profile.n_unlocks # @TODO: which one is deprecated?

if @profile.current_city
  json.current_city @profile.current_city
end

json.bookmarks @profile.bookmarks do |b|
  json.name b.name
  json.slug b.slug
end

