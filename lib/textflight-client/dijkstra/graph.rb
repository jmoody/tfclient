
class Graph
  attr_accessor :nodes
  attr_accessor :edges

  def initialize
    @nodes = []
    @edges = []
  end

  def contains_node?(node)
    @nodes.any? { |n| n.name == node.name }
  end

  def find_node(node_or_name)
    if node_or_name.is_a?(String)
      @nodes.detect { |node| node.name == node_or_name }
    else
      @nodes.detect { |node| node == node_or_name }
    end
  end

  def add_node(node)
    if node.nil? || node.name.nil?
      binding.pry
    end

    if !contains_node?(node)
      nodes << node
    end
    node.graph = self
  end

  def contains_edge?(edge)
    @edges.any? do |e|
      (e.to == edge.to   && e.from == edge.from) ||
      (e.to == edge.from && e.from == edge.to)
    end
  end

  def add_edge(from, to, weight, direction = nil)
    if from.nil? || to.nil?
      binding.pry
    end

    if from.name.nil? || to.name.nil?
      binding.pry
    end

    if from.graph.nil? || to.graph.nil?
      binding.pry
    end

    if from.graph != to.graph
      binding.pry
    end

    edge = Edge.new(from, to, weight, direction)
    if !contains_edge?(edge)
      edges << edge
    end
  end

  def to_s
    %Q[#<Graph nodes = #{@nodes.count} edges = #{@edges.count}>]
  end

  def inspect; to_s; end
end
