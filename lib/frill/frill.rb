module Frill
  def self.included(base)
    self.decorators.add base
    base.extend ClassMethods
  end

  def self.decorators
    @decorators ||= Graph.new
  end

  def self.reset!
    @decorators = nil
  end

  def self.decorate object, context
   decorators.sorted_nodes.each do |d|
     object.extend d if d.frill? object, context
   end

   object
  end

  module ClassMethods
    def before decorator
      Frill.decorators.move_before self, decorator
    end

    def after decorator
      Frill.decorators.move_after self, decorator
    end
  end

  class Graph
    def initialize
      @nodes = {}
    end

    def add label
      @nodes[label] ||= Node.new label
    end

    def move_before label1, label2
      node1 = add label1
      node2 = add label2

      node1.move_before node2
    end

    def move_after label1, label2
      node1 = add label1
      node2 = add label2

      node1.move_after node2
    end

    def [](label)
      @nodes[label]
    end

    def empty?
      @nodes.empty?
    end

    def include? label
      @nodes.keys.include? label
    end

    def index label
      sorted_nodes.index label
    end

    def sorted_nodes
      lists = []

      @nodes.values.each do |node|
        unless lists.include? node.label
          leaf = node.leaf
          lists += leaf.to_a
        end
      end

      lists
    end

    class Node
      attr_accessor :parent, :child
      attr_reader :label

      def initialize(label)
        @label  = label
        @parent = nil
        @child  = nil
      end

      def move_before node
        parent_node = node.leaf

        parent_node.child = self
        self.parent = parent_node
      end

      def move_after node
        child_node = node.root

        self.child = child_node
        child.parent = self
      end

      def leaf
        node = nil
        current_node = self

        until node
          if current_node.child
            current_node = current_node.child
          else
            node = current_node
          end
        end

        node
      end

      def root
        current_node = self
        root_node = nil

        until root_node
          if current_node.parent
            current_node = current_node.parent
          else
            root_node = current_node
          end
        end

        root_node
      end

      def to_a
        current_node = self

        list = []

        until current_node == nil
          list << current_node.label
          current_node = current_node.parent
        end

        list
      end
    end
  end
end
