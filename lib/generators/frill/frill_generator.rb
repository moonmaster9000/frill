module Rails
  module Generators
    class FrillGenerator < NamedBase
      source_root File.expand_path("../templates", __FILE__)
      check_class_collision suffix: "Frill"


      def create_frill_file
        template 'frill.rb', File.join('app/frills/', class_path, "#{file_name}_frill.rb")
      end

      hook_for :test_framework

    end
  end
end

