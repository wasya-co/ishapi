require 'spec_helper'

describe "routes for users, accounts" do
  routes { Ishapi::Engine.routes }

  it "show my account" do
    expect( :get => '/my/account' ).to route_to( 'ishapi/users#account' )
  end

end

