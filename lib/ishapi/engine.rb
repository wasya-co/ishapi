
require 'rubygems'
require 'rack/throttle'
require 'jbuilder' # _vp_ 2022-10-07 - otherwise host app cant find templates

module Ishapi
  class Engine < ::Rails::Engine
    isolate_namespace Ishapi
    # config.middleware.use Rack::Throttle::Interval, :min => 1.0, :max => 10
  end
end
