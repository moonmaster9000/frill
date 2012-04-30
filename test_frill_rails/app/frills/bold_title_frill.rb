module BoldTitleFrill
  include Frill
  after PrettyTitleFrill

  def self.frill? object, context
    context.request.format == "text/html"
  end

  def title
    helper.content_tag :b, "#{super} #{helper.root_url}"
  end
end
