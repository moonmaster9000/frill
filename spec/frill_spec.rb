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

  describe ".decorate" do
    let(:object)         { double :object  }
    let(:object_context) { double :object_context }
    let(:eigenclass)     { (class << object; self; end) }

    let!(:applicable_module) do
      Module.new do
        include Frill

        def self.frill? object, context
          true
        end
      end
    end

    let!(:unapplicable_module) do
      Module.new do
        include Frill

        def self.frill? object, context
          false
        end
      end
    end

    it "should decorate the object with any applicable modules" do
      Frill.decorate object, object_context

      eigenclass.included_modules.should include applicable_module
      eigenclass.included_modules.should_not include unapplicable_module
    end
  end

  describe ".included" do
    let(:test_module) { double :module }

    subject { Frill.decorators }

    before { Frill.included test_module }

    it { should include test_module }
  end

  describe Frill::ClassMethods do
    let(:module1) { Module.new { include Frill } }
    let(:module2) { Module.new { include Frill } }

    describe ".before" do
      it "inserts the current module before the requested module in Frill's list of decorators" do
        Frill.decorators.should == [module1, module2]

        module2.before module1
        Frill.decorators.should == [module2, module1]
      end
    end

    describe ".after" do
      it "inserts the current module after the requested module in Frill's list of decorators" do
        Frill.decorators.should == [module1, module2]

        module1.after module2
        Frill.decorators.should == [module2, module1]
      end
    end

    describe ".first" do
      it "inserts the current module at the beginning of the list of Frill's decorators" do
        Frill.decorators.should == [module1, module2]

        module2.first
        Frill.decorators.should == [module2, module1]
      end
    end
  end
end