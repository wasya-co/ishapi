require 'spec_helper'

describe Ishapi::Users::RegistrationsController do
  render_views
  routes { Ishapi::Engine.routes }
  before :each do
    do_setup
  end

  # Alphabetized : )

  describe 'Register' do
    it '' do
      n_u = User.all.count
      n_p = Profile.all.count

      @request.env["devise.mapping"] = Devise.mappings[:user]
      post :create, params: { user: { email: 'test@email.com', password: 'test1234' } }

      User.all.count.should eql( n_u + 1 )
      Profile.all.count.should eql( n_p + 1 )
    end
  end

end
