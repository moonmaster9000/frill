class AutoFrillController < ApplicationController
  auto_frill
  respond_to :html

  def index
    @model = Model.new
    respond_with @model
  end
end
