

json.name     @profile.name
# json.username @profile.username
json.email    @profile.email

json.n_reports   @profile.reports.count
json.n_galleries @profile.galleries.count
json.n_videos    @profile.videos.count
json.n_stars     @profile.n_stars

json.n_unlocks @profile.n_unlocks

if @profile.current_city
  json.current_city @profile.current_city
end

json.bookmarks @profile.bookmarks do |b|
  json.name b.name
  json.slug b.slug
end

