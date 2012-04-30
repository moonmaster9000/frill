module PrettyTitleFrill
  include Frill

  def self.frill?(*)
    true
  end

  def title
    "Decorated #{super} is Pretty"
  end
end
