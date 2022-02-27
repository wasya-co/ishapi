
require 'spec_helper'

describe Ishapi::SitesController do
  render_views
  routes { Ishapi::Engine.routes }

  before do
    @user = create(:user)
    @site = create(:site, domain: 'new-domain')
    @gallery = create :gallery, user_profile: @user.profile
    @site.newsitems << Newsitem.create({ gallery: @gallery })
  end

  context '#show' do
    it 'newsitems have item_type' do
      get :show, :format => :json, params: { domain: @site.domain }
      response.should be_successful
      result = JSON.parse response.body
      result['newsitems'][0]['item_type'].should eql 'Gallery'
    end
  end

end
