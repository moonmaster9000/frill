module BoldTitleFrill
  include Frill
  after PrettyTitleFrill

  def self.frill? object, context
    context.request.format.html?
  end

  def title
    h.content_tag :b, "#{super} #{helpers.root_url}"
  end
end
