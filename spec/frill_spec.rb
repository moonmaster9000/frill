require_relative '../lib/frill/frill'

describe Frill do
  before do
    Frill.reset!
  end

  describe ".reset" do
    before do
      Frill.decorators << Module.new
      Frill.decorators.should_not be_empty
    end

    it "should wipe out all decorators" do
      Frill.reset!
      Frill.decorators.should be_empty
    end
  end

  describe ".included" do
    let(:test_module) { double :module }

    subject { Frill.decorators }

    before { Frill.included test_module }

    it { should include test_module }
  end
end
