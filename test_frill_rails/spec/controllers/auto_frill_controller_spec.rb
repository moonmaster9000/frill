require "spec_helper"

describe AutoFrillController do
  render_views

  describe "GET#index" do
    it "should render a frill'ed model" do
      get :index
      response.body.should include "Decorated Title"
    end
  end
end
