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
      post :create, params: { user: { email: 'test@email.com', password: 'test1234' } }

      puts! response.body, 'ze Response'

      response.code.should eql '200'
    end
  end

end
