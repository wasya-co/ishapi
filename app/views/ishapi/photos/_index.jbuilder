
#
# ishapi / photos / _index
# @deprecated, ishapi / galleries / _show is preferred
#

json.photos do
  json.array! photos do |photo|
    json.partial! 'ishapi/photos/show', :photo => photo
  end
end
