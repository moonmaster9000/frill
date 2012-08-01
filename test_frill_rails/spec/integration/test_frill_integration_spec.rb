require 'spec_helper'

describe 'Frill integration' do
  it "should decorate models" do
    visit root_path
    page.should have_content "Decorated Title"
  end

  it "should let you frill inside the view" do
    visit associations_path
    page.should have_content "Decorated Title"
  end
end
