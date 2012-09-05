module Frill
  module RSpec
    module Helpers
      def frill model, options={}
        view_context = ApplicationController.new.view_context.tap do |context|
          context.controller.request ||= ActionController::TestRequest.new options
          context.request            ||= context.controller.request
          context.params             ||= {}
        end

        Frill.decorate model, view_context
      end
    end
  end
end

module Frill
  module RSpec
    module ExampleGroup
      def self.included(base)
        base.metadata[:type] = :frill
        base.send :include, Frill::RSpec::Helpers
      end
    end
  end
end

RSpec.configure do |config|
  config.include Frill::RSpec::ExampleGroup, :type => :frill, :example_group => {
    :file_path => /spec[\\\/]frills/
  }
end
