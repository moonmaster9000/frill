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

  it "should let you opt in to automatic frilling by using the auto_frill method in a controller" do
    visit auto_frill_path
    page.should have_content "Decorated Title"
  end

  it "should let you optionally specify a subset of frills to decorate with" do
    visit frill_subset_path
    page.should have_content "Title http://www.example.com"
  end
end
