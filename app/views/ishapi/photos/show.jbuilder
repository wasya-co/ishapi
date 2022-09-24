
json.photo do
  json.partial! 'ishapi/photos/show', photo: @photo
  json.item_type 'Photo'
end

