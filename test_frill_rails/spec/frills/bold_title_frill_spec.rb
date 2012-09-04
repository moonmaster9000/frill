require 'spec_helper'

describe BoldTitleFrill do
  let(:model) {
    Class.new do
      def title; "foo"; end
    end.new
  }

  subject { frill model }

  its(:title) { should == "<b>Decorated foo is Pretty http://test.host/</b>" }
end