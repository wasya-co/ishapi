require 'spec_helper'
describe Ishapi::PaymentsController do
  render_views
  routes { Ishapi::Engine.routes }
  before :each do
    do_setup
    @user.profile.update_attributes n_unlocks: 5
  end

  describe '#unlock' do
    before do
      ::Gameui::PremiumPurchase.destroy_all
      @jwt_token = encode({ user_id: @user.id.to_s })
    end

    it 'happy path, and duplicates are not unlocked' do
      @report.update_attributes({ premium_tier: 1 })
      ::Gameui::PremiumPurchase.all.count.should eql 0
      @user.profile.premium_purchases.where( user_profile_id: @user.profile.id, item: @report ).count.should eql 0
      @user.profile.n_unlocks.should eql 5

      post :unlock, params: { kind: 'Report', id: @report.id, jwt_token: @jwt_token }, format: :json
      response.should be_successful
      ::Gameui::PremiumPurchase.all.count.should eql 1

      @user.profile.reload
      @user.profile.n_unlocks.should eql 4
      @user.profile.has_premium_purchase( @report ).should eql true
      ::Gameui::PremiumPurchase.unscoped.where( user_profile_id: @user.profile.id, item: @report ).count.should eql 1

      # duplicates are not unlocked
      post :unlock, params: { kind: 'Report', id: @report.id, jwt_token: @jwt_token }, format: :json
      ::Gameui::PremiumPurchase.where( user_profile_id: @user.profile.id, item: @report ).count.should eql 1
    end
  end

end
