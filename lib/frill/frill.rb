module Frill
  class CyclicDependency < RuntimeError; end

  def self.included base
    self.dependency_graph.add base
    base.extend ClassMethods
  end

  def self.decorators
    @decorators ||= dependency_graph.to_a
  end

  def self.reset!
    @decorators = nil
    @dependency_graph = nil
  end

  def self.decorate object, context
   decorators.each do |d|
     object.extend d if d.frill? object, context
   end

   object
  end

  def self.dependency_graph
    @dependency_graph ||= DependencyGraph.new
  end

  module ClassMethods
    def before decorator
      Frill.dependency_graph.move_before self, decorator
    end

    def after decorator
      Frill.dependency_graph.move_before decorator, self
    end
  end

  class DependencyGraph
    def initialize
      @nodes = {}
    end

    def add label
      nodes[label] ||= Node.new label
    end

    def move_before label1, label2
      node1 = add label1
      node2 = add label2

      node1.move_before node2

      CycleDetecter.detect! nodes
    end

    def [](label)
      nodes[label]
    end

    def empty?
      nodes.empty?
    end

    def include? label
      nodes[label]
    end

    def index label
      to_a.index label
    end

    def to_a
      array = []

      nodes.values.each do |node|
        array += construct_array(node) unless array.include? node.label
      end

      array
    end

    private
    attr_reader :nodes

    def construct_array node
      array = []
      current_node = node.first

      while current_node
        array << current_node.label
        current_node = current_node.next
      end

      array
    end

    class CycleDetecter
      def self.detect! nodes
        new(nodes).detect!
      end

      def initialize nodes
        @nodes = nodes
        @visited = {}
      end

      def detect!
        nodes.values.each do |node|
          fan_out node unless visited[node.label]
        end
      end

      private
      attr_reader :nodes, :visited

      def fan_out node
        visited[node.label] = true

        fan :next, node
        fan :previous, node
      end

      def fan direction, start_node
        current_node = start_node.send direction

        while current_node
          raise Frill::CyclicDependency if visited[current_node.label]
          visited[current_node.label] = true
          current_node = current_node.send direction
        end
      end
    end

    class Node
      attr_accessor :next, :previous
      attr_reader :label

      def initialize(label)
        @label  = label
        @next = nil
        @previous  = nil
      end

      def move_before node
        next_node = node.first
        previous_node = self.last

        previous_node.next = next_node
        next_node.previous = previous_node
      end

      def first
        first_node = self
        first_node = first_node.previous while first_node.previous
        first_node
      end

      def last
        last_node = self
        last_node = last_node.next while last_node.next
        last_node
      end
    end
  end
end
