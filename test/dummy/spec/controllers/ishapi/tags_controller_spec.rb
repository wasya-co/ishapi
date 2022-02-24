
require 'spec_helper'

describe Ishapi::TagsController do
  render_views
  routes { Ishapi::Engine.routes }
  before :each do
    do_setup
  end

=begin
  context '#show' do
    it 'all reports have a photo' do
      get :show, params: { slug: @tag.slug }
      response.should be_success
      result = JSON.parse response.body
      result['reports'][0]['photo']['thumb_url'].should_not eql nil
    end
  end
=end

end
