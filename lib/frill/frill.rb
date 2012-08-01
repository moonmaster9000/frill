module Frill
  def self.included(base)
    self.decorators << base
    base.extend ClassMethods
  end

  def self.decorators
    @decorators ||= []
  end

  def self.reset!
    @decorators = nil
  end

  def self.decorate object, context
    decorators.each do |d|
      object.extend d if d.frill? object, context
    end

    object
  end

  module ClassMethods
    def before decorator
      move Frill.decorators.index(decorator)
    end

    def after decorator
      decorator.before self
    end

    def first
      move 0
    end

    private
    def move index
      Frill.decorators.delete self
      Frill.decorators.insert index, self
    end
  end
end
