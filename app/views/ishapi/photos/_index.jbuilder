
#
# ishapi / photos / _index
# @deprecated, ishapi / galleries / _show is preferred
#

json.photos do
  json.array! photos do |photo|

    json.mini_url     photo.photo.url( :mini  )
    json.thumb_url    photo.photo.url( :thumb2 )
    json.small_url    photo.photo.url( :small )
    json.large_url    photo.photo.url( :large )
    json.original_url photo.photo.url( :original )

    json.name         photo.name

  end
end
