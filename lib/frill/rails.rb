module Frill
  module Auto
    def view_assigns
      new_hash = {}

      super.each do |key,value|
        new_hash[key] = frill value
      end

      new_hash
    end
  end
end

module ActionController
  class Base
    def self.auto_frill
      self.send :include, Frill::Auto
    end

    helper_method :frill 

    private
    def frill object, options={}
      RailsFrillHelper.new(object, self, options).frill
    end

    class RailsFrillHelper
      def initialize(object, controller, options)
        @object = object
        @controller = controller
        @options = options
      end

      def frill
        extend_with_view_context
        frill_object
        object
      end

      private
      attr_reader :options, :object, :controller

      def frill_object
        objects.each do |o|
          Frill.decorate o, controller, options
        end
      end

      def extend_with_view_context
        options[:with] << ViewContextFrill if options[:with]
      end

      def objects
        if object.respond_to? :each
          object
        else
          [object]
        end
      end
    end
  end
end
