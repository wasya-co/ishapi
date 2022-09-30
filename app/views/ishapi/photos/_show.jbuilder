
#
# ishapi / photos / _show
#

json.mini_url     photo.photo.url( :mini  )
json.thumb_url    photo.photo.url( :thumb )
json.small_url    photo.photo.url( :small )
json.large_url    photo.photo.url( :large )
json.original_url photo.photo.url( :original )

json.subhead photo.subhead
