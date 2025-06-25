require_relative "lib/pay/woo/version"

Gem::Specification.new do |spec|
  spec.name        = "pay-woo"
  spec.version     = Pay::Woo::VERSION
  spec.authors     = [ "oliwoodsuk" ]
  spec.email       = [ "55204545+oliwoodsuk@users.noreply.github.com" ]
  spec.homepage    = "https://github.com/pay-rails/pay-woo"
  spec.summary     = "WooCommerce billing integration for Pay gem"
  spec.description = "A Ruby gem that extends the Pay gem to support WooCommerce billing and subscription management"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/pay-rails/pay-woo"
  spec.metadata["changelog_uri"] = "https://github.com/pay-rails/pay-woo/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0"
  spec.add_dependency "pay", "~> 11.1"
  spec.add_dependency "httparty", "~> 0.22"

  spec.add_development_dependency "webmock", "~> 3"
  spec.add_development_dependency "vcr", "~> 6"
  spec.add_development_dependency "dotenv-rails", "~> 2"
end
