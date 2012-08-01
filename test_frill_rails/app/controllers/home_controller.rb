class HomeController < ApplicationController
  respond_to :html

  def index
    @model = frill Model.new
    respond_with @model
  end

  def associations
    @model = Model.new
  end
end
