require 'spec_helper'
describe 'route ish_manager galleries' do
  routes { Ishapi::Engine.routes }

  it 'index_titles' do
    expect( :get => '/galleries' ).to route_to( 'ishapi/galleries#index' )
  end

end
