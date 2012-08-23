Gem::Specification.new do |s|
  s.name       = "frill"
  s.authors    = "Matt Parker"
  s.email      = "moonmaster9000@gmail.com"
  s.homepage   = "https://github.com/moonmaster9000/frill"
  s.version    = File.read "VERSION"
  s.files      = Dir["lib/**/*"] + Dir["app/**/*"] << "VERSION" << "readme.markdown" << "LICENSE"
  s.test_files = Dir["spec/**/*"]
  s.summary    = "Decorating objects for presentation. Supports Rails out of the box."

  s.add_development_dependency "rails", "~> 3.2.2"

  %w[rspec rspec-rails capybara pry].each do |library|
    s.add_development_dependency library
  end
end
