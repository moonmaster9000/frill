class HomeController < ApplicationController
  respond_to :html

  def index
    @model = frill Model.new
    respond_with @model
  end

  def associations
    @model = Model.new
  end

  def frill_subset
    @model = frill Model.new, with: [BoldTitleFrill]
    respond_with @model, template: "home/index"
  end
end
