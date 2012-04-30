class ActionController::Base
  def frill object
    Frill.decorate object, self
  end
end
