require 'spec_helper'

describe Ishapi::UsersController do
  render_views
  routes { Ishapi::Engine.routes }
  before :each do
    do_setup
  end

  # Alphabetized : )

  describe '#account' do
    it 'renders' do
      @jwt_token = encode(user_profile_id: @profile.id.to_s)
      get :account, format: :json, params: { jwt_token: @jwt_token }
      response.should be_successful
    end
  end

end
