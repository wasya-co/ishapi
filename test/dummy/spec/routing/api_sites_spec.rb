require 'spec_helper'
describe 'routes of api sites' do
  routes { Ishapi::Engine.routes }

  it 'show a site' do
    expect( :get => '/sites/view/local.com.json' ).to route_to( 'ishapi/sites#show', :domain => 'local.com.json' )
    expect( :get => '/sites/view/local.com' ).to route_to( 'ishapi/sites#show', :domain => 'local.com' )
  end

end
