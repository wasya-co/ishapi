require 'spec_helper'

describe Ishapi::EmailMessagesController do
  render_views
  routes { Ishapi::Engine.routes }
  before :each do
    do_setup
    @object_key = "jdlh9e7db1apuamt7iufcq810vj5pu8oqe7hq8o1"
  end

  describe '#receive' do
    it 'errors unless auth' do
      AWS_SES_LAMBDA_SECRET = 'some-secret'
      n = Office::EmailMessageStub.all.length
      post :receive, params: { object_key: @object_key, secret: 'wrong-secret' }
      Office::EmailMessageStub.all.length.should eql( n )
    end

    it 'receives' do
      AWS_SES_LAMBDA_SECRET = 'some-secret'
      n = Office::EmailMessageStub.all.length
      post :receive, params: { object_key: @object_key, secret: 'some-secret' }
      Office::EmailMessageStub.all.length.should eql( n + 1 )
    end
  end

end
