require 'spec_helper'

describe Ishapi::MapsController do
  render_views
  routes { Ishapi::Engine.routes }
  before :each do
    do_setup

    Gameui::Map.destroy_all
    Gameui::Marker.destroy_all

    @map = FactoryBot.create :map
    @map.image = Ish::ImageAsset.create({
      image: File.open( Rails.root.join( 'data', 'photo.png' ) ),
    })
    @marker = create(:marker,
      creator_profile: create(:user),
      map: @map,
    )
    @map.save
    @marker_image = create(:image_asset, marker_id: @marker.id)
    @marker_title_image = create(:image_asset, marker_title_id: @marker.id)
  end

  describe '#show' do
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
      )
      @map.save
      @marker_image = create(:image_asset, marker_id: @marker.id)

      get :show, format: :json, params: { slug: @map.slug }

      response.code.should eql '200'
      result = JSON.parse response.body
      result['map']['newsitems'].should_not eql nil
    end

    it 'markers have premium_tier' do
      get :show, format: :json, params: { slug: @map.slug }
      result = JSON.parse response.body
      result['map']['markers'][0].should_not eql nil
      result['map']['markers'][0]['premium_tier'].should_not eql nil
    end
  end

end
