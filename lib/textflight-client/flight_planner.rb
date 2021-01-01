
module TFClient

  class FlightPlanner

    require_relative "./models/client/system"

    def self.create_graph
      graph = Graph.new
      systems = TFClient::Models::Client::System.find_by_sql("select * from systems")
      systems.each do |system|
        sys_node = Node.new(system.system_id)
        graph.add_node(sys_node)

        system.links_array.each do |link|
          direction = link[1]
          weight = link[2]
          link_sys, coord = system.system_in_direction(direction: direction)
          if link_sys.nil?
            system_id = "coordinate: #{coord.x} #{coord.y}"
          else
            system_id = link_sys.system_id
          end

          link_node = Node.new(system_id)
          graph.add_node(link_node)
          graph.add_edge(sys_node, link_node, weight, direction)
        end
      end

      graph
    end

    attr_reader :origin, :destination
    attr_reader :graph

    def initialize(origin:, destination:)
      @origin = origin
      @destination = destination

      if @origin == @destination
        message = <<~EOM
        origin and destination are the same, you are already at your destination.
        
             origin: '#{origin}'
        destination: '#{destination}'
        EOM
        raise(ArgumentError, message)
      end

      @graph = FlightPlanner.create_graph

      @origin_node = @graph.find_node(@origin)
      @destination_node = @graph.find_node(@destination)

      if @origin_node.nil? || @destination_node.nil?
        message = <<~EOM
        origin and destination need to be in the graph:

             origin: '#{@origin}'
        destination: '#{@destination}'
        EOM

        raise(ArgumentError, message)
      end
    end

    def plan
      result = Dijkstra.new(@graph, @origin_node).shortest_path_to(@destination_node)
      if result.nil? || result.empty?
        TFClient.log_info(
          "Could not find a path between #{@origin} and #{@destination}"
        )
        nil
      end

      binding.pry

      directions = []
      index = 0
      loop do
        origin = result[index]
        destination = result[index + 1]
        break if destination.nil?

        edge = origin.adjacent_edges.detect do |e|
          e.from == destination || e.to == destination
        end

        directions << edge.direction

        index = index + 1
      end

      directions
    end
  end
end