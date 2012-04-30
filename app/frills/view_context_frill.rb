module ViewContextFrill
  include Frill
  first

  def self.frill? object, controller
    object.class_eval do
      define_method :helper do
        @frill_helper ||= controller.view_context
      end
    end

    false
  end
end
