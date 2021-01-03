module TFClient
  class CommandParser

    DIRECTION_MAP = {
      n: "6",
      ne: "7",
      e: "4",
      se: "2",
      s: "1",
      sw: "0",
      w: "3",
      nw: "5"
    }

    # 0: 315 degrees, X=-1, Y=-1 (northwest)
    # 1: 0 degrees, X=0, Y=-1 (north)
    # 2: 45 degrees, X=1, Y=-1 (northeast)
    # 3: 270 degrees, X=-1, Y=0 (west)
    # 4: 90 degrees, X=1, Y=0 (east)
    # 5: 225 degrees, X=-1, Y=1 (southwest)
    # 6: 180 degrees, X=0, Y=-1 (south)
    # 7: 135 degrees, X=1, Y=-1 (southeast)

    attr_reader :command
    def initialize(command:)
      @command = command
    end

    def parse
      if @command == "quit" || @command == "exit"
        return "exit"
      end

      direction = DIRECTION_MAP[@command.to_sym]
      if direction
        "jump #{direction}"
      else
        @command
      end
    end

    def is_plot_course?
      @command.strip[/plot course to/]
    end

    def plot_course(x:, y:)
      destination = @command.strip

      if destination[/(\d+|-\d+){2}/]
        xy = destination.scan(/\d+|-\d+/).map { |num| num.to_i }
        coord = TFClient::Models::Client::Coordinate.new(x: xy[0],
                                                         y: xy[1])
        target =
          TFClient::Models::Client::System.system_for_coordinate(coordinate: coord)

        coord = TFClient::Models::Client::Coordinate.new(x: x, y: y)
        source =
          TFClient::Models::Client::System.system_for_coordinate(coordinate: coord)

        TFClient::FlightPlanner.new(source: source.system_id,
                                    target: target.system_id).plan
      else
        name = destination.split(" ").last
        if name == ""
          puts %Q[Usage: plot course to {<system> | <x> <y>}]
          return nil
        end

        system = TFClient::Models::Client::System.system_for_name(name: name)
        if system.nil? || system.empty?
          puts %Q[Cannot find system with name '#{name}']
          return nil
        elsif system.count != 1
          puts %Q[Found more than one system with name '#{name}']
          puts %Q[=> #{system.join(" ")}]
          return nil
        else
          target = system.first

          coord = TFClient::Models::Client::Coordinate.new(x: x, y: y)
          source =
            TFClient::Models::Client::System.system_for_coordinate(coordinate: coord)

          TFClient::FlightPlanner.new(source: source.system_id,
                                      target: target.system_id).plan
        end
      end
    end
  end
end