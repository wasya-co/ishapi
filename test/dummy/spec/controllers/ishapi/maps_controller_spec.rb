require 'spec_helper'

describe Ishapi::MapsController do
  render_views
  routes { Ishapi::Engine.routes }
  before :each do
    # do_setup
    # Gameui::Map.destroy_all
    # Gameui::Marker.destroy_all

    @map = FactoryBot.create :map
    @map_2 = FactoryBot.create :map
    @map_3 = FactoryBot.create :map
    @map.image = Ish::ImageAsset.create({
      image: File.open( Rails.root.join( 'data', 'photo.png' ) ),
    })
    @marker = create(:marker,
      creator_profile: create(:user),
      map: @map,
      destination: @map_2
    )
    @map.save
    @marker_image = create(:image_asset, marker_id: @marker.id)
    @marker_title_image = create(:image_asset, marker_title_id: @marker.id)
  end

  describe '#show' do
    it 'helper image_missing' do
      get :show, format: :json, params: { slug: @map_2.slug }
      response.code.should eql '200'
      response.body.should include("https://s3.amazonaws.com/ish-wp/wp-content/uploads/2022/02/25232018/100x100_crossout.png")
    end

    it 'renders' do
      get :show, format: :json, params: { slug: @map.slug }
      response.code.should eql '200'
    end

    it 'newsitems is never nil, even if empty' do
      @map = FactoryBot.create :map
      @map.image = Ish::ImageAsset.create({
        image: File.open( Rails.root.join( 'data', 'photo.png' ) ),
      })
      @marker = create(:marker,
        creator_profile: create(:user),
        map: @map,
        destination: @map_3,
      )
      @map.save
      @marker_image = create(:image_asset, marker_id: @marker.id)

      get :show, format: :json, params: { slug: @map.slug }

      response.code.should eql '200'
      result = JSON.parse response.body
      result['map']['newsitems'].should_not eql nil
    end

    it 'markers have premium_tier, id of the destination' do
      get :show, format: :json, params: { slug: @map.slug }
      result = JSON.parse response.body
      result['map']['markers'][0].should_not eql nil
      result['map']['markers'][0]['premium_tier'].should_not eql nil
      result['map']['markers'][0]['id'].should eql @marker.destination.id.to_s
    end
  end

end
