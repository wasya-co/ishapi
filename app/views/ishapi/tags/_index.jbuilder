
##
## ishapi / tags / _index
##

json.tags do
  json.array! tags do |tag|
    json.id   tag.id.to_s
    json.name tag.name
    json.slug tag.slug
  end
end


