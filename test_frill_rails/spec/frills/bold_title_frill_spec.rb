require 'spec_helper'

describe BoldTitleFrill do
  let(:model) {
    Class.new do
      def title; "foo"; end
    end.new
  }

  context "html request" do
    subject { frill model }
    its(:title) { should == "<b>Decorated foo is Pretty http://test.host/</b>" }
  end

  context "json request" do
    subject { frill model, "HTTP_ACCEPT" => "application/json" }
    its(:title) { should == "Decorated foo is Pretty" }
  end
end
