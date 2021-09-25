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

end
