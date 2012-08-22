module Frill
  class CyclicDependency < RuntimeError; end

  def self.included(base)
    self.list.add base
    base.extend ClassMethods
  end

  def self.decorators
    list.to_a
  end

  def self.reset!
    @list = nil
  end

  def self.decorate object, context
   decorators.each do |d|
     object.extend d if d.frill? object, context
   end

   object
  end

  def self.list
    @list ||= List.new
  end

  module ClassMethods
    def before decorator
      Frill.list.move_before self, decorator
    end

    def after decorator
      Frill.list.move_before decorator, self
    end
  end

  class List
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

      detect_cycles
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
      to_a.index label
    end

    def to_a
      lists = []

      @nodes.values.each do |node|
        unless lists.include? node.label
          first = node.first
          lists += first.to_a
        end
      end

      lists
    end

    private

    def detect_cycles
      @nodes.values.each do |node|
        visited = {}
        visited[node.label] = true

        current_node = node.next
        while current_node
          raise Frill::CyclicDependency if visited[current_node.label]
          visited[current_node.label] = true
          current_node = current_node.next
        end

        current_node = node.previous
        while current_node
          raise Frill::CyclicDependency if visited[current_node.label]
          visited[current_node.label] = true
          current_node = current_node.previous
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
        node = nil
        current_node = self

        until node
          if current_node.previous
            current_node = current_node.previous
          else
            node = current_node
          end
        end

        node
      end

      def last
        current_node = self
        last_node = nil

        until last_node
          if current_node.next
            current_node = current_node.next
          else
            last_node = current_node
          end
        end

        last_node
      end

      def to_a
        current_node = self

        list = []

        until current_node == nil
          list << current_node.label
          current_node = current_node.next
        end

        list
      end
    end
  end
end
