module Rspec
  class FrillGenerator < ::Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    def create_spec_file
      template 'frill_spec.rb', File.join('spec/frills', "#{singular_name}_frill_spec.rb")
    end
  end
end