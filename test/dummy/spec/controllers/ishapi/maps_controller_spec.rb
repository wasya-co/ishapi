require 'spec_helper'

describe Ishapi::MapsController do
  render_views
  routes { Ishapi::Engine.routes }
  before :each do
    do_setup

    Gameui::Map.destroy_all
    @map = FactoryBot.create :map
    @map.image = Ish::ImageAsset.create({
      image: File.open( Rails.root.join( 'data', 'photo.png' ) ),
    })
    @map.save
  end

  describe '#show' do
    it 'renders' do
      get :show, format: :json, params: { slug: @map.slug }
      response.should be_success
    end

    it 'newsitems is never nil, even if empty' do
      get :show, format: :json, params: { slug: @map.slug }
      response.should be_success
      result = JSON.parse response.body
      result['map']['newsitems'].should_not eql nil
    end
  end

end
