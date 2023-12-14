require_relative "lib/ishapi3/version"

Gem::Specification.new do |spec|
  spec.name        = "ishapi3"
  spec.version     = Ishapi3::VERSION
  spec.authors     = ["mac_a2141"]
  spec.email       = ["victor@piousbox.com"]
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
