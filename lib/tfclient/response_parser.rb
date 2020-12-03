
module TFClient
  class ResponseParser

    FIELD_DELIMITER = "|".freeze

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

    def self.tokenize_lines(line)
      tokens = line.strip.split(FIELD_DELIMITER)
      tokens.map { |token| token.strip }
    end

    attr_reader :command
    attr_reader :response
    def initialize(command:, response:)
      @command = command
      @response = response
    end

    def parse
      lines = response.lines(chomp: true).reject { |line| line.length == 0 }
      case command
      when "nav"
        parse_nav(lines)
      end
    end

    def parse_nav(lines:)
      nav = lines.dup
      response = []
      response << Coordinate.new(ResponseParser.tokenize_lines(nav[0])).to_s
      response << Brightness.new(ResponseParser.tokenize_lines(nav[1])).to_s
      response << Asteroids.new(ResponseParser.tokenize_lines(nav[2])).to_s
    end
  end

  class Coordinate
    attr_reader :x, :y, :label, :translation

    def initialize(tokens:)
      @label = tokens[0].split(":")[0]
      @translation = tokens[1].split(":")[0]
      @x = tokens[tokens.length - 2].split("=")[1]
      @y = tokens[tokens.length - 1].split("=")[1]
    end

    def to_s
      %Q[#{@translation}: #{@x},#{@y}]
    end
  end

  class Brightness
    attr_reader :value, :label, :translation, :percent

    def initialize(tokens:)
      @label = tokens[0].split(":")[0]
      @translation = tokens[1].split(":")[0]
      @value = tokens[tokens.length - 1].split("=")[1].to_i
      @percent = (@value/255) * 100
    end

    def to_s
      %Q[#{@translation}: #{@value} => #{@percent}%]
    end
  end

  class Asteroids
    attr_reader :value, :label, :translation, :ore, :density

    def initialize(tokens:)
      @label = tokens[0].split(":")[0]
      @translation = tokens[1].split(":")[0]
      @ore = tokens[tokens.length - 2].split("=")[1]
      @density = tokens[tokens.length - 1].split("=")[1].to_i
      @percent = (@density/7) * 100
    end

    def to_s
      %Q[#{@translation}: #{@ore} #{@density} => #{@percent}%]
    end
  end
end