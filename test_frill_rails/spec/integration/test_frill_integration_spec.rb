require 'spec_helper'

describe 'Frill integration' do
  it "should work" do
    visit root_path
    page.should have_content "Decorated Title"
  end
end
