require 'spec_helper'
describe Ishapi::PaymentsController do
  render_views
  routes { Ishapi::Engine.routes }
  before :each do
    do_setup
    allow(controller).to receive(:current_user).and_return( User.new({ profile: ::Ish::UserProfile.new }) )
    allow(controller).to receive(:decode).and_return({ 'user_id' => @user.id })

    @user.reload
    @user.profile.update_attributes n_unlocks: 5
  end

  describe '#unlock' do
    before do
      ::Gameui::PremiumPurchase.destroy_all
    end

    it 'happy path, and duplicates are not unlocked' do
      ::Gameui::PremiumPurchase.all.count.should eql 0
      @user.profile.premium_purchases.where( user_profile_id: @user.profile.id, item: @report ).count.should eql 0
      @user.profile.n_unlocks.should eql 5

      post :unlock, params: { kind: 'Report', id: @report.id }, format: :json
      response.should be_successful
      ::Gameui::PremiumPurchase.all.count.should eql 1

      @user.reload
      @user.profile.n_unlocks.should eql 4
      @user.profile.has_premium_purchase( @report ).should eql true
      ::Gameui::PremiumPurchase.unscoped.where( user_profile_id: @user.profile.id, item: @report ).count.should eql 1

      # duplicates are not unlocked
      post :unlock, params: { kind: 'Report', id: @report.id }, format: :json
      ::Gameui::PremiumPurchase.where( user_profile_id: @user.profile.id, item: @report ).count.should eql 1
    end
  end

end
