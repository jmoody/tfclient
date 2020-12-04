
module TFClient
  module Models
    LINK_MAP = {
      "0" => "sw",
      "1" => "s",
      "2" => "se",
      "3" => "w",
      "4" => "e",
      "5" => "nw",
      "6" => "n",
      "7" => "ne"
    }

    # 0: 315 degrees, X=-1, Y=-1 (northwest)
    # 1: 0 degrees, X=0, Y=-1 (north)
    # 2: 45 degrees, X=1, Y=-1 (northeast)
    # 3: 270 degrees, X=-1, Y=0 (west)
    # 4: 90 degrees, X=1, Y=0 (east)
    # 5: 225 degrees, X=-1, Y=1 (southwest)
    # 6: 180 degrees, X=0, Y=-1 (south)
    # 7: 135 degrees, X=1, Y=-1 (southeast)

    class Coordinate
      attr_reader :x, :y, :label, :translation

      def initialize(tokens:)
        hash = TFClient::ResponseParser.label_and_translation(tokens: tokens)
        @label = hash[:label]
        @translation = hash[:translation]
        @x = TFClient::ResponseParser.nth_value_from_end(tokens: tokens, n: 1).to_i
        @y = TFClient::ResponseParser.nth_value_from_end(tokens: tokens, n: 0).to_i
      end

      def to_s
        %Q[#{@translation}: #{@x},#{@y}]
      end
    end

    class Brightness
      attr_reader :brightness, :label, :translation, :percent

      def initialize(tokens:)
        @label = tokens[0].split(":")[0]
        @translation = tokens[1].split(":")[0]
        @brightness = tokens[tokens.length - 1].split("=")[1].to_i
        @percent = ((@brightness/255.0) * 100).round
      end

      def to_s
        %Q[#{@translation}: #{@brightness} => #{@percent}%]
      end
    end

    class Asteroids
      attr_reader :brightness, :label, :translation, :ore, :density, :percent

      def initialize(tokens:)
        @label = tokens[0].split(":")[0]
        @translation = tokens[1].split(":")[0]
        @ore = tokens[tokens.length - 2].split("=")[1]
        @density = tokens[tokens.length - 1].split("=")[1].to_i
        @percent = ((@density/7.0) * 100).round
      end

      def to_s
        %Q[#{@translation}: #{@ore} (#{@density}) => #{@percent}%]
      end
    end
  end
end