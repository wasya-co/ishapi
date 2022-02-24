require 'spec_helper'

class KoalaMock
  def get_object *args
    return { 'email' => 'test@gmail.com' }
  end
end

describe Ishapi::ApplicationController do
  render_views
  routes { Ishapi::Engine.routes }
  before :each do
    do_setup
    # allow(controller).to receive(:current_user).and_return(UserStub.new({ :manager => false }))

    allow(HTTParty).to receive(:get).and_return(OpenStruct.new({ body: "{}" }))
    allow(Koala::Facebook::API).to receive(:new).and_return(KoalaMock.new)
  end

  it '#long_term_token' do
    post :long_term_token
    response.should be_success
    result = JSON.parse response.body
    result['email'].should_not be nil
    result['n_unlocks'].should_not be nil
    puts! result, 'ze-result-1'
  end

end
