require 'spec_helper'

describe Ishapi::GalleriesController do
  render_views
  routes { Ishapi::Engine.routes }
  before :each do
    do_setup
  end

  it '#index' do
    get :index
    response.should be_success
  end

  describe '#show' do
    it 'renders id of a premium gallery' do
      @gallery.update_attributes( premium_tier: 2 )
      get :show, params: { galleryname: @gallery.slug }
      response.should be_success
      result = JSON.parse(response.body).deep_symbolize_keys!
      result[:message].should eql "This is premium content - please purchase it to view!"
      result[:gallery][:id].should_not eql nil
      result[:gallery][:id].class.should eql String
    end
  end

end
