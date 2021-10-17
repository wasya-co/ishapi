
#
# ishapi / application / _meta
#

if !item.tags.blank?
  json.partial! 'ishapi/tags/index', tags: item.tags
end
json.created_at  item.created_at
json.updated_at  item.updated_at
json.username    item.user_profile.name if item.user_profile
if item.city
  json.city do
    json.name item.city.name
    json.slug item.city.cityname
  end
  json.cityname    item.city.cityname
end
json.subhead     item.subhead
json.description item.descr
