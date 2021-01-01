
RSpec.describe Edge do
  it "#==" do
    a = Node.new("a")
    b = Node.new("b")

    e0 = Edge.new(a, b, 10)

    expect(e0).to be == Edge.new(a, b, 10)
    expect(e0).to be == Edge.new(b, a, 10)

    expect(e0).not_to be == Edge.new(a, Node.new("c"), 10)
  end
end

RSpec.describe Graph do
  let(:graph) { Graph.new }
  let(:a) { Node.new("a") }
  let(:b) { Node.new("b") }
  let(:c) { Node.new("c") }

  before do
    graph.add_node(a)
    graph.add_node(b)
    graph.add_node(c)

    graph.add_edge(a, b, 10)
    graph.add_edge(a, c, 10)
  end

  context ".contains_node?" do
    it "returns true if the graph contains the node (by name)" do
      expect(graph.contains_node?(Node.new("a"))).to be == true
    end

    it "returns false if the graph does not contain the node" do
      expect(graph.contains_node?(Node.new("d"))).to be == false
    end
  end

  context ".add_node" do
    it "adds the node if it does not already exist" do
      graph.add_node(Node.new("d"))
      expect(graph.nodes.count).to be == 4
    end

    it "does not add the node if already exists" do
      graph.add_node(Node.new("a"))
      expect(graph.nodes.count).to be == 3
    end
  end

  context ".contains_edge?" do
    it "returns true if the graph contains the edge" do
      edge = Edge.new(a, b, 0)
      expect(graph.contains_edge?(edge)).to be == true

      edge = Edge.new(b, a, 0)
      expect(graph.contains_edge?(edge)).to be == true

      edge = Edge.new(c, a, 0)
      expect(graph.contains_edge?(edge)).to be == true

      edge = Edge.new(a, c, 0)
      expect(graph.contains_edge?(edge)).to be == true
    end

    it "returns false if the graph does not contain the edge" do
      edge = Edge.new(b, c, 0)
      expect(graph.contains_edge?(edge)).to be == false

      edge = Edge.new(c, b, 0)
      expect(graph.contains_edge?(edge)).to be == false
    end
  end

  context ".add_edge" do
    it "adds the edge if the graph does not contain the edge" do
      graph.add_edge(b, c, 10)
      expect(graph.edges.count).to be == 3
    end

    it "does not add the edge if the graph contains the edge" do
      graph.add_edge(a, b, 10)
      expect(graph.edges.count).to be == 2
    end
  end
end