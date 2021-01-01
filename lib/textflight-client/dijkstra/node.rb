
class Node
  attr_accessor :name, :graph

  def initialize(name)
    if name.nil? || name == ""
      raise "name needs to be non-null and non-empty"
    end
    @name = name
  end

  def hash
    @name.hash
  end

  def eql?(other)
    @name == other.name
  end

  def ==(other)
    @name == other.name
  end

  def !=(other)
    @name != other.name
  end

  def adjacent_edges
    graph.edges.select{|e| e.from == self}
  end

  def to_s
    %Q[#<Node '#{@name}'>]
  end

  def inspect; to_s; end
end
