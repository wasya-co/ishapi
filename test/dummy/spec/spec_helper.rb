ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment.rb", __FILE__)
require 'rspec/rails'
require 'devise'

## From: https://github.com/DatabaseCleaner/database_cleaner-mongoid
DatabaseCleaner.clean


RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.infer_spec_type_from_file_location!
  # config.include Devise::TestHelpers, :type => :helper
  config.include Devise::Test::ControllerHelpers, :type => :controller
  Warden.test_mode!
end

def puts! a, b=''
  puts "+++ +++ #{b}"
  puts a.inspect
end

def do_setup
  DatabaseCleaner.clean

  User.all.destroy_all
  Profile.all.destroy_all
  @user = @fake_user = create(:user, :email => 'test@gmail.com')
  @profile = create( :profile, email: 'test@gmail.com' )

  Gallery.all.destroy_all
  @gallery = create :gallery, user_profile: @user.profile

  @report = create :report

end

Paperclip.options[:log] = false

# jwt
def encode(payload, exp = 2.hours.from_now)
  payload[:exp] = exp.to_i
  JWT.encode(payload, Rails.application.secrets.secret_key_base.to_s)
end

def user_confirmation_url opts={}
  '/'
end
