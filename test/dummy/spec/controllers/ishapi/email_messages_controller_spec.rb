require 'spec_helper'

describe Ishapi::EmailMessagesController do
  render_views
  routes { Ishapi::Engine.routes }
  before :each do
    do_setup
  end

  describe '#receive' do
    it 'errors unless auth' do
      AWS_SES_LAMBDA_SECRET = 'some-secret'
      n = Office::EmailMessage.count
      post :receive, params: { object_path: 'some-path', secret: 'wrong-secret' }
      Office::EmailMessage.count.should eql( n )
    end

    it 'receives' do
      some_path = "https://ish-ses.s3.amazonaws.com/jdlh9e7db1apuamt7iufcq810vj5pu8oqe7hq8o1"
      AWS_SES_LAMBDA_SECRET = 'some-secret'
      n = Office::EmailMessage.count
      post :receive, params: { object_path: some_path, secret: 'some-secret' }
      Office::EmailMessage.count.should eql( n + 1 )
    end
  end

end
