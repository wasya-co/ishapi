require 'spec_helper'
describe Ishapi::ReportsController do
  render_views
  routes { Ishapi::Engine.routes }
  before :each do
    do_setup
    allow(controller).to receive(:current_user).and_return( User.new({ profile: ::Ish::UserProfile.new }) )
    @report.photo = Photo.create :photo => File.open( Rails.root.join 'data', 'photo.png' )
    @report.save.should eql true
  end

  context '#index' do
    it 'renders' do
      get :index, :format => :json
      response.should be_successful
    end

    it 'shows all the images, not just thumb' do
      skip 'skip for now, not a priority.'

      get :index, :format => :json
      results = JSON.parse response.body
      results[0]['photos']['thumb_url'].should_not eql nil
    end
  end

  context '#show' do
    it 'renders' do
      get :show, :params => { :slug => @report.slug }
      response.should be_successful
      response.should render_template 'show'
    end

    it 'shows all images' do
      get :show, :params => { :slug => @report.slug }
      results = JSON.parse response.body
      results['photo']['large_url'].should_not eql nil
    end
  end

end
