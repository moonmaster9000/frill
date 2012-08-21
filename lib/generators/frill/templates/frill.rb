<% module_namespacing do -%>
module <%= class_name %>Frill 
  include Frill

  # Decorating before or after another frill:
  #   after SomeFrill
  # or...
  #   before SomeFrill

  # frill? tells Frill when to decorate an object with this module.
  # If you're decorating within a controller action via the `frill`
  # method, then the context is the controller instance.
  # This would allow you to scope this frill to only certain types
  # of requests (e.g., context.request.json?)
  def self.frill?(object, context)
    false
  end

  # Decorate methods on `object`. 
  # If you want to use a view helper like `link_to` or a route helper like
  # `root_path`, use the `helpers` method (or its short alias, `h`) to access them:
  # def created_at
  #   h.content_tag :b, super
  # end
end
<% end -%>
