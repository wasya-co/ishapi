require_relative "lib/ishapi/version"

Gem::Specification.new do |spec|
  spec.name        = "ishapi"
  spec.version     = Ishapi::VERSION
  spec.authors     = ["Victor Pudeyev"]
  spec.email       = ["victor@wasya.co"]
  spec.homepage    = "https://wasya.co"
  spec.summary     = "https://wasya.co"
  spec.description = "https://wasya.co"
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://wasya.co"
  spec.metadata["changelog_uri"] = "https://wasya.co"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.1.7", ">= 6.1.7.6"
end
