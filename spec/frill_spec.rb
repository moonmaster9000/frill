require_relative '../lib/frill/frill'

describe Frill do
  before do
    Frill.reset!
  end

  describe ".reset" do
    before do
      Module.new { include Frill }
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
    before do
      module Module2; include Frill; end
      module Module1; include Frill; end
      module Module5; include Frill; end
      module Module4; include Frill; end
      module Module3; include Frill; end
    end

    describe ".before" do
      it "inserts the current module before the requested module in Frill's list of decorators" do
        Module5.before Module4
        Module4.before Module3
        Module3.before Module2
        Module2.before Module1

        Frill.decorators.index(Module5).should be < Frill.decorators.index(Module4)
        Frill.decorators.index(Module3).should be < Frill.decorators.index(Module2)
        Frill.decorators.index(Module2).should be < Frill.decorators.index(Module1)
        Frill.decorators.index(Module4).should be < Frill.decorators.index(Module3)
      end
    end 
  end

  describe Frill::ClassMethods do
    before do
      module Module1; include Frill; end
      module Module2; include Frill; end
      module Module3; include Frill; end
    end

    describe ".before" do
      it "inserts the current module before the requested module in Frill's list of decorators" do
        Frill.decorators.sorted_nodes.should == [Module1, Module2, Module3]

        Module1.before Module2
        Frill.decorators.sorted_nodes.should == [Module1, Module2, Module3]

        Module3.before Module2
        Frill.decorators.sorted_nodes.should == [Module3, Module1, Module2]
      end
    end

    describe ".after" do
      it "inserts the current module after the requested module in Frill's list of decorators" do
        Frill.decorators.sorted_nodes.should == [Module1, Module2, Module3]

        Module1.after Module2
        Module3.after Module2

        Frill.decorators.sorted_nodes.first.should == Module2
        Frill.decorators.sorted_nodes.last(2).should =~ [Module1, Module3]
      end
    end
  end

  describe Frill::Graph do 
    describe "#add" do
      it "should add an element to the graph" do
        g = Frill::Graph.new
        g.add "hi"
        g["hi"].should_not be_nil
      end
    end

    describe "#move_before(label1, label2)" do
      it "should move label1 before label2" do
        g = Frill::Graph.new
        g.move_before "a", "b"
        g.sorted_nodes.should == ["a", "b"]
      end
    end

    describe "#move_after(label1, label2)" do
      it "should move label1 after label2" do
        g = Frill::Graph.new
        g.move_after "a", "b"
        g.sorted_nodes.should == ["b", "a"]
      end
    end
  end
end
