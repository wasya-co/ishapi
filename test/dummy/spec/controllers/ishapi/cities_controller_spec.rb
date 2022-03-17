
require 'spec_helper'

describe Ishapi::CitiesController do
  render_views
  routes { Ishapi::Engine.routes }
  before do
    do_setup
  end

  it '#index' do
    get :index, format: :json
    response.should be_successful
  end

  it '#show' do
    get :show, params: { cityname: @city.cityname }
    response.should be_successful
    response.should render_template 'show'
  end

end
