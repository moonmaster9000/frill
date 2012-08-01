module Frill
  module ActiveRecord
    class AssociationDecorator
      def self.decorate(object, context)
        new(object, context).decorate
      end

      def initialize(object, context)
        @object  = object
        @context = context
      end

      def decorate
        embed_context_in_object
        decorate_associations
      end

      private
      def embed_context_in_object
        frill_context = @context

        object.extend(
          Module.new do 
            private
            define_method(:__frill_context) do
              frill_context
            end
          end
        )
      end

      def decorate_associations
        object.class.reflect_on_all_associations.each do |association|
          if association.collection?
            object.extend(
              Module.new.tap do |mod|
                mod.class_eval <<-EVAL
                  def #{association.name}
                    Frill::ActiveRecord::CollectionProxy.new(super, __frill_context)
                  end
                EVAL
              end
            )
          else
            object.extend(
              Module.new.tap do |mod|
                mod.class_eval <<-EVAL
                  def #{association.name}
                    association = super
                    return nil unless association
                    Frill.decorate association, __frill_context
                  end
                EVAL
              end
            )
          end
        end
      end

      attr_reader :object, :context
    end
  end
end
