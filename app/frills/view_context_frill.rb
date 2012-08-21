module ViewContextFrill
  include Frill

  def self.frill? object, controller
    object.class_eval do
      define_method :helpers do
        @frill_helper ||= controller.view_context
      end

      define_method :h do
        helpers
      end

      private :h, :helpers
    end

    false
  end
end
