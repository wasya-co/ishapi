
#
# ishapi / features / _index
#

resource ||= site if defined? site
resource ||= city if defined? city

json.n_features features.count
json.features do
  json.array! features.limit( resource.n_features ) do |feature|

    json.name       feature.name       unless feature.name.blank?
    json.subhead    feature.subhead    unless feature.subhead.blank?
    json.link_path  feature.link_path  unless feature.link_path.blank?
    json.inner_html feature.inner_html unless feature.inner_html.blank?
    json.photo_url  feature.image_path unless feature.image_path.blank?
    json.created_at feature.created_at
    
    if feature.report
      r = feature.report
      json.name       r.name
      json.subhead    r.subhead
      json.reportname r.slug
      if r.photo
        json.photo_url  r.photo.photo.url( :thumb )
      end
    end
    
    if feature.gallery
      r = feature.gallery
      json.name        r.name
      json.subhead     r.subhead
      json.slug r.galleryname
      if r.photos[0]
        json.photo_url r.photos[0].photo.url( :thumb )
      end
    end

  end
end
