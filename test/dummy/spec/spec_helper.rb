ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment.rb", __FILE__)
require 'rspec/rails'
require 'devise'

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.include Devise::TestHelpers, :type => :helper
  config.include Devise::Test::ControllerHelpers, :type => :controller
end

def puts! a, b=''
  puts "+++ +++ #{b}"
  puts a.inspect
end

class UserStub
  def initialize args = {}
    user        = User.find_or_create_by!( email: 'test@gmail.com' )
    @profile    = IshModels::UserProfile.find_or_create_by!( email: 'test@gmail.com', name: 'name', user: user )

    # address     = CoTailors::Address.find_or_create_by( :name => 'abba-addr', :address_1 => 'blahblah 1' )
    # measurement = CoTailors::ProfileMeasurement.create :neck_around => 22.2
    # order       = CoTailors::Order.create
    if args[:manager]
      @profile.email = 'manager@gmail.com'; @profile.save
    end
  end

  def profile= profile
    @profile = profile
  end

  def profile
    return @profile
  end
end

def do_setup
  User.unscoped.destroy
  @user = @fake_user = User.create! :email => 'test@gmail.com', :password => '123412341234'

  IshModels::UserProfile.unscoped.destroy
  @fake_profile = IshModels::UserProfile.create! :email => 'test@gmail.com', :name => 'Profile Name', user: @user
  @user.profile = @fake_profile; @user.save

=begin
  @fake_measurements = CoTailors::ProfileMeasurement.create :neck_around => 22.2,
                                                            :units => CoTailors::ProfileMeasurement::UNITS_INCHES,
                                                            :profile => @fake_profile
  @fake_address = CoTailors::Address.create :name => 'addr-name', :address_1 => 'addr-1', :profile => @fake_profile
=end

  City.unscoped.destroy
  @city         = City.create( :name => 'xx-test-city', :cityname => 'text-cityname' )
  # @feature_city = City.create( :name => 'feature city', :cityname => 'feature-city', :is_feature => true )

  Gallery.unscoped.destroy
  @gallery = FactoryBot.create :gallery

  Report.unscoped.destroy
  @report = FactoryBot.create :report

  Site.unscoped.destroy
  @site = FactoryBot.create :site
  @site.newsitems << Newsitem.create({ gallery: @gallery })

  Tag.unscoped.destroy
  @tag = FactoryBot.create :tag
end

Paperclip.options[:log] = false

# jwt
def encode(payload, exp = 2.hours.from_now)
  payload[:exp] = exp.to_i
  JWT.encode(payload, Rails.application.secrets.secret_key_base.to_s)
end
