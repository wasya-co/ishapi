require 'spec_helper'

describe Ishapi::MapsController do
  render_views
  routes { Ishapi::Engine.routes }
  before :each do
    do_setup

    Gameui::Map.destroy_all
    @map = FactoryBot.create :map
    @map.image = Ish::ImageAsset.create({ image: File.open( Rails.root.join( 'data', 'photo.png' ) ) })
    @map.save
  end

  describe '#show' do
    it 'renders' do
      get :show, format: :json, params: { slug: @map.slug }
      response.should be_success
    end
  end

end
