require 'spec_helper'
describe Ishapi::My::GalleriesController do
  render_views
  routes { Ishapi::Engine.routes }
  before :each do
    do_setup
  end

  it '#index' do
    skip 'skip for now - implement it later, not a priority.'

    g = FactoryBot.create(:gallery, name: 'quick name', slug: 'quick-name', user_profile: @user.profile)

    get :index, format: :json
    response.should be_success
    response.should render_template('ishapi/galleries/index')

    json = JSON.parse response.body
    assert json.length > 0
  end

end
