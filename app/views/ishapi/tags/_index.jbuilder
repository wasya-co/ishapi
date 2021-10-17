
##
## ishapi / tags / _index
##

json.tags do
  json.array! tags do |tag|
    json.name tag.name
    json.slug tag.slug
  end
end


