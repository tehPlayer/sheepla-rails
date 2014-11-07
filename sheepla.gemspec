$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sheepla/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sheepla"
  s.version     = Sheepla::VERSION
  s.authors     = ["Marcin Jan Adamczyk"]
  s.email       = ["marcin.adamczyk@subcom.me"]
  s.homepage    = "http://www.subcom.me/"
  s.summary     = "Sheepla API wrapper"
  s.description = "Sheepla API wrapper"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "nokogiri", "~> 1.6.4"
  s.add_dependency "rails", "~> 4.0.0"

  s.add_development_dependency "sqlite3"
end
