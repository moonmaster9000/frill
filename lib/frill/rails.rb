module ActionController
  class Base
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
