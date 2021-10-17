
#
# ishapi / tags / index
#

json.array! @tags do |tag|
  json.name tag.name
  json.slug tag.slug
end

