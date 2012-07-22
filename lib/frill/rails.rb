module ActionController
  class Base

    private
    def frill object
      Frill.decorate object, self
    end
  end
end
