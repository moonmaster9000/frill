module ViewContextFrill
  include Frill

  def self.frill? object, context
    object.class_eval do
      define_method :helpers do
        @frill_helper ||= context.respond_to?(:view_context) ? context.view_context : context
      end

      define_method :h do
        helpers
      end

      private :h, :helpers
    end

    false
  end
end
