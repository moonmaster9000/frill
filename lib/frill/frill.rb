module Frill
  def self.included(base)
    self.decorators << base
  end

  def self.decorators
    @decorators ||= []
  end

  def self.reset!
    @decorators = nil
  end
end
