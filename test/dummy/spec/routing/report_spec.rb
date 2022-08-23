require 'spec_helper'
describe 'route api/reports' do
  routes { Ishapi::Engine.routes }

  it 'show' do
    expect( :get => '/reports/view/some_report.json' ).to route_to( 'ishapi/reports#show', :format => 'json', :slug => 'some_report' )
  end  

end
