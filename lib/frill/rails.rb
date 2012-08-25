module Frill
  module Auto
    protected

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
    def frill object
      if object.respond_to?(:each)
        object.each do |o|
          Frill.decorate o, self
        end
      else
        Frill.decorate object, self
      end
    end
  end
end
