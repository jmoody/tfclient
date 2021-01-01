
module TFClient

  class Graph
    require "rgl/dijkstra"
    require "rgl/dijkstra_visitor"
    require "rgl/adjacency"

    attr_reader :rgl_graph
    attr_reader :edge_weights, :edge_weights_lambda
    attr_reader :directions

    def initialize
      @edge_weights = {}
      @edge_weights_lambda = lambda { |edge| @edge_weights[edge] }
      @directions = {}
      @rgl_graph = RGL::AdjacencyGraph.new
    end

    def add_vertex(vertex:)
      @rgl_graph.add_vertex(vertex)
    end

    def add_edge(source:, target:, weight:, direction:)
      @rgl_graph.add_edge(source, target)
      @edge_weights[[source, target]] = weight
      @directions[[source, target]] = direction
    end

    def shortest_path(source:, target:)
      visitor = RGL::DijkstraVisitor.new(@rgl_graph)
      dijkstra = RGL::DijkstraAlgorithm.new(@rgl_graph,
                                            @edge_weights_lambda,
                                            visitor)
      vertices = dijkstra.shortest_path(source, target)
      if vertices.nil? || vertices.empty?
        nil
      else
        directions(vertices: vertices)
      end
    end

    def directions(vertices:)
      directions = []
      index = 0
      loop do
        source = vertices[index]
        break if source.nil?

        target = vertices[index + 1]
        break if target.nil?

        direction = @directions[[source, target]] || @directions[[target, source]]
        if direction.nil?
          binding.pry
          raise "Cannot find #{[source, target]} in directions map"
        end

        directions << direction
        index = index + 1
      end
      directions
    end
  end

  class FlightPlanner
    require_relative "./models/client/system"

    def self.create_graph
      graph = TFClient::Graph.new
      systems = TFClient::Models::Client::System.find_by_sql("select * from systems")
      systems.each do |system|
        graph.add_vertex(vertex: system.system_id)

        system.links_array.each do |link|
          direction = link[1]
          weight = link[2]
          link_sys, coord = system.system_in_direction(direction: direction)
          if link_sys.nil?
            link_system_id = "coordinate: #{coord.x} #{coord.y}"
          else
            link_system_id = link_sys.system_id
          end
          graph.add_vertex(vertex: link_system_id)
          graph.add_edge(source: system.system_id,
                         target: link_system_id,
                         weight: weight,
                         direction: direction)
        end
      end
      graph
    end

    attr_reader :source, :target, :graph

    def initialize(source:, target:)
      @source = source
      @target = target

      if @source == @target
        message = <<~EOM
        source and target are the same, you are already at your destination.
        
        target: '#{source}'
        source: '#{target}'
        EOM
        raise(ArgumentError, message)
      end

      @graph = FlightPlanner.create_graph
    end

    def plan
      @graph.shortest_path(source: @source, target: @target)
    end
  end
end