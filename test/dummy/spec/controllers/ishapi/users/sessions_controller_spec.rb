
require 'spec_helper'

describe Ishapi::Users::SessionsController do
  render_views
  routes { Ishapi::Engine.routes }
  before :each do
    do_setup
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  # Alphabetized : )

  describe '#login' do
    it 'sends jwt_token' do
      @user.update_attributes( confirmed_at: Time.now )
      post :create, format: :json, params: { user: { email: @user.email, password: '1234567890' } }
      response.code.should eql '200'
      result = JSON.parse response.body
      result['jwt_token'].should_not be nil
    end

    it 'does not login a user if email is not verified' do
      @user.update_attributes( confirmed_at: nil )
      post :create, format: :json, params: { email: @user.email, password: '1234567890' }
      response.code.should eql '401'
    end
  end

end
