
#
# ishapi / reports / _index
#

json.n_reports reports.count
json.reports do
  json.array! reports do |report|
    # json.id          report.id.to_s
    json.created_at  report.created_at
    json.name        report.name
    json.slug        report.slug
    json.description report.descr

    if report.photo
      json.photo do
        json.thumb_url report.photo.photo.url :thumb
        json.small_url report.photo.photo.url :small
        json.large_url report.photo.photo.url :large
      end
    end

    json.partial! 'ishapi/tags/index', tags: report.tags unless report.tags.blank?

  end
end
