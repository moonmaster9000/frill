module ViewContextFrill
  include Frill
  first

  def self.frill? object, controller
    object.class_eval do
      define_method :helper do
        @frill_helper ||= controller.view_context
      end

      define_method :h do
        helper
      end

      define_method :helpers do
        helper
      end

      private :helper, :h, :helpers
    end

    false
  end
end
