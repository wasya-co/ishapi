$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ishapi/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ishapi"
  s.version     = "0.1.8.184"
  s.authors     = ["piousbox"]
  s.email       = ["piousbox@gmail.com"]
  s.homepage    = "http://wasya.co"
  s.summary     = "Summary of Ishapi."
  s.description = " Description of Ishapi."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 6.0.0"
  s.add_dependency 'mongoid', "~> 7.3.0"
  s.add_runtime_dependency 'mongoid-paperclip'
  s.add_runtime_dependency 'mongoid_paranoia'
  s.add_dependency 'cancancan', "~> 2.0"
  s.add_dependency "kaminari-mongoid", "~> 1.0"
  s.add_dependency "kaminari-actionview", "~> 1.0"
  s.add_dependency "koala", "~> 3.0"
  s.add_dependency "googleauth", "~> 0.8.0"
  s.add_dependency "fb_graph"
  s.add_dependency "mongoid-autoinc", "~> 6.0"
  s.add_dependency "rack-throttle", "~> 0.5"
  s.add_dependency "jbuilder", "~> 2.7"
  s.add_dependency "aws-sdk"
  s.add_dependency "stripe"
  s.add_dependency "httparty"
  s.add_dependency "devise"

end
