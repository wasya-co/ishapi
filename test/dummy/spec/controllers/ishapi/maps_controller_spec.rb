require 'spec_helper'

describe Ishapi::MapsController do
  render_views
  routes { Ishapi::Engine.routes }
  before :each do
    @map = create :map
    @map_2 = create :map
    @map_3 = create :map
    @marker = create(:marker,
      creator_profile: create(:user),
      map: @map,
      destination: @map_2
    )
  end

  describe '#show' do
    it 'finds by slug = id' do
      get :show, format: :json, params: { slug: @map_2.id.to_s }
      response.code.should eql '200'
    end

    describe 'free or purchased' do

      it 'renders, sets: w, h, newsitems even if empty, is_purchased is_premium *always*, ' do
        get :show, format: :json, params: { slug: @map.slug }

        response.code.should eql '200'
        result = JSON.parse(response.body).deep_symbolize_keys!

        [ :w, :h, :newsitems, :is_premium, :is_purchased ].each do |sym|
          result[:map][sym].should_not eql( nil ), "#{sym} cannot be empty!"
        end
      end

      it 'sets: newsitems_pagination' do
        create(:newsitem, map: @map)

        get :show, format: :json, params: { slug: @map.slug }

        result = JSON.parse(response.body).deep_symbolize_keys!

        [ :newsitems_pagination ].each do |sym|
          result[:map][sym].should_not eql( nil ), "#{sym} cannot be empty!"
        end
      end

      it 'shows its own config even if parent is present. example: 3D -> geodesic' do
        parent = create(:map)
        map = create(:map, parent: parent, parent_slug: parent.slug, config: '{ "a": "b" }' )
        get :show, format: :json, params: { slug: map.slug }
        result = JSON.parse response.body
        result['map']['config'].should eql({ 'a' => 'b' })
      end

      context 'markers' do
        it 'have premium_tier, destination_slug' do
          get :show, format: :json, params: { slug: @map.slug }
          result = JSON.parse response.body
          result['map']['markers'][0].should_not eql nil
          result['map']['markers'][0]['premium_tier'].should_not eql nil
          result['map']['markers'][0]['destination_slug'].should_not eql nil
          result['map']['markers'][0]['destination_slug'].should eql @marker.destination.slug
          result['map']['markers'][0]['id'].should eql @marker.destination.id.to_s ## @TODO: Not sure I agree with this. _vp_ 2022-09-17
        end

        ## @TODO: it appears whatever a user has purchased belongs to its own object or the user,
        ##   not to the map. So, refactor this. _vp_ 2022-09-17
        it 'is_purchased' do
          get :show, format: :json, params: { slug: @map.slug }
          result = JSON.parse response.body
          result['map']['markers'][0]['id'].should eql @map_2.id.to_s ## @TODO: Not sure I agree with this. _vp_ 2022-09-17
          result['map']['markers'][0]['is_purchased'].should be_falsey

          @map_2.update_attributes({ premium_tier: 1 })
          get :show, format: :json, params: { slug: @map.slug }
          result = JSON.parse response.body
          result['map']['markers'][0]['is_purchased'].should be_falsey

          user_2    = create(:user)
          profile_2 = create(:user_profile, email: user_2.email)
          create(:premium_purchase, item: @map_2, user_profile: user_2.profile)
          allow(controller).to receive(:current_user).and_return( user_2 )

          get :show, format: :json, params: { slug: @map.slug }
          result = JSON.parse response.body
          result['map']['markers'][0]['is_purchased'].should be_truthy
        end
      end

    end
    describe 'premium not purchased' do

      it 'does not display newsitems' do
        map = create(:map, premium_tier: 1)
        get :show, format: :json, params: { slug: map.slug }
        result = JSON.parse response.body
        %w| newsitems tags map |.each do |sym|
          result['map'][sym].should eql( nil )
        end
      end

    end
    describe 'premium purchased' do

      it 'says its purchased' do
        map      = create(:map, premium_tier: 1)
        user     = create(:user)
        profile  = create(:user_profile, email: user.email)
        purchase = create(:purchase, item: map, user_profile: profile)
        get :show, format: :json, params: { slug: map.slug }
        result = JSON.parse response.body
        (!!result['map']['is_purchased']).should eql false

        jwt_token = encode(user_id: user.id.to_s)
        get :show, format: :json, params: { jwt_token: jwt_token, slug: map.slug }
        result = JSON.parse response.body
        result['map']['is_purchased'].should eql true
      end

    end

  end

end
