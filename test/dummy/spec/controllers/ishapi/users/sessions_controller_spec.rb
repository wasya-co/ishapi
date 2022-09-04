

require 'spec_helper'

describe Ishapi::Users::SessionsController do
  render_views
  routes { Ishapi::Engine.routes }
  before :each do
    do_setup
  end

  # Alphabetized : )

  describe '#login' do
    it 'sends jwt_token' do
      post :create, format: :json, params: { email: @user.email, password: '1234567890' }
      response.code.should eql '200'

      result = JSON.parse response.body
      result['jwt_token'].should_not be nil
    end

    it 'does not login a user if email is not verified' do
      raise 'not implemented'
    end

  end

end
