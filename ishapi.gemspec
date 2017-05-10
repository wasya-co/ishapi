$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ishapi/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ishapi"
  s.version     = Ishapi::VERSION
  s.authors     = ["piousbox"]
  s.email       = ["piousbox@gmail.com"]
  s.homepage    = "http://wasya.co"
  s.summary     = "Summary of Ishapi."
  s.description = " Description of Ishapi."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1.0"

  s.add_development_dependency "sqlite3"
end