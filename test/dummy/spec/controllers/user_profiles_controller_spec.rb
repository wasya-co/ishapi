require 'spec_helper'

describe Ishapi::UserProfilesController do
  render_views
  routes { Ishapi::Engine.routes }
  before :each do
    do_setup
    allow(controller).to receive(:current_user).and_return(@fake_user) # UserStub.new({ :manager => false }))
  end
=begin
  it '#my' do
    get :my, :format => :json
    response.should be_success
    result = JSON.parse response.body
    result['n_unlocks'].should_not eql nil
  end
=end
end
