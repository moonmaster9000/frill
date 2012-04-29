Gem::Specification.new do |s|
  s.name       = "frill"
  s.authors    = "Matt Parker"
  s.email      = "moonmaster9000@gmail.com"
  s.version    = File.read "VERSION"
  s.files      = Dir["lib/**/*"] << "VERSION" << "readme.markdown"
  s.test_files = Dir["spec/**/*"]

  s.add_development_dependency "rails", "~> 3.2.2"
  s.add_development_dependency "rspec"
end
