#
# ishapi / newsitems / _index
#

json.n_newsitems newsitems.count
json.newsitems do
  json.array! newsitems do |item|

    json.id          item.id.to_s
    json.name        item.name
    json.created_at  item.created_at
    json.updated_at  item.updated_at

    if item.gallery
      json.item_type    'gallery'
      json.name         item.gallery.name
      json.galleryname  item.gallery.galleryname
      json.username     item.username || item.gallery.username || 'piousbox'
      json.n_photos     item.gallery.photos.length
      json.slug         item.gallery.galleryname
      json.subhead      item.gallery.subhead
      json.partial!    'ishapi/application/meta', :item => item.gallery
      if item.gallery.is_premium
        json.premium_tier item.gallery.premium_tier
        json.is_premium   item.gallery.premium_tier > 0
        json.is_purchased current_user&.profile&.has_premium_purchase( item.gallery )
        json.partial!    'ishapi/photos/index',     :photos => [ item.gallery.photos[0] ]
      else
        json.partial!    'ishapi/photos/index',     :photos => item.gallery.photos
      end
    end

    if item.report
      json.item_type  'report'
      json.name       item.report.name
      json.reportname item.report.name_seo
      json.subhead    item.report.subhead
      json.report_id  item.report_id.to_s
      json.username   item.report.user_profile.name if item.report.user_profile

      if item.report.photo
        json.photo_s169_url item.report.photo.photo.url( :s169 )
        json.photo_thumb2_url item.report.photo.photo.url( :thumb2 )
      end

      json.partial! 'ishapi/application/meta', :item => item.report

      if item.report.is_premium
        json.premium_tier item.report.premium_tier
        json.is_premium   item.report.premium_tier > 0
        json.is_purchased current_user&.profile&.has_premium_purchase( item.report )
      end
    end

    if item.video_id
      json.partial! 'ishapi/videos/show', :video => Video.unscoped.find( item.video_id )
    end

    if item.photo
      json.item_type 'photo'
      json.partial! 'ishapi/photos/index', :photos => [ item.photo ]
    end

  end
end
