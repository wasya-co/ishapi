require_relative 'boot'

require 'rails/all'

# require "action_controller/railtie"
# require "action_mailer/railtie"
# # require "sprockets/railtie"
# require "rails/test_unit/railtie"
# # require 'active_record/railtie' # sqlite?

require_relative './initializers/00_s3.rb'

Bundler.require(*Rails.groups)
require 'ish_models'
require "ishapi"

module Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end

