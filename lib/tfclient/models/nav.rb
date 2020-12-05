
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
    # 6: 180 degrees, X=0, Y=-1 (south) # bug should be 0,1
    # 7: 135 degrees, X=1, Y=-1 (southeast) # bug should be 1,1

    class Model
      attr_accessor :label, :translation
      def initialize(label:, translation:)
        @label = label
        @translation = translation
      end
    end

    class Coordinate < Model
      attr_reader :x, :y

      def initialize(tokens:)
        hash = TFClient::ResponseParser.label_and_translation(tokens: tokens)
        super(label: hash[:label], translation: hash[:translation] )
        @x = TFClient::ResponseParser.nth_value_from_end(tokens: tokens, n: 1).to_i
        @y = TFClient::ResponseParser.nth_value_from_end(tokens: tokens, n: 0).to_i
      end

      def to_s
        %Q[#{@translation}: #{@x},#{@y}]
      end
    end

    class Brightness < Model
      attr_reader :brightness, :percent

      def initialize(tokens:)
        hash = TFClient::ResponseParser.label_and_translation(tokens: tokens)
        super(label: hash[:label], translation: hash[:translation] )
        @brightness = TFClient::ResponseParser.nth_value_from_end(tokens: tokens, n: 0).to_i
        @percent = ((@brightness/255.0) * 100).round
      end

      def to_s
        %Q[#{@translation}: #{@brightness} => #{@percent}%]
      end
    end

    class Asteroids < Model
      attr_reader :brightness, :ore, :density, :percent

      def initialize(tokens:)
        hash = TFClient::ResponseParser.label_and_translation(tokens: tokens)
        super(label: hash[:label], translation: hash[:translation])
        @ore = TFClient::ResponseParser.nth_value_from_end(tokens: tokens, n: 1)
        @density = TFClient::ResponseParser.nth_value_from_end(tokens: tokens, n: 0).to_i
        @density = tokens[tokens.length - 1].split("=")[1].to_i
        @percent = ((@density/7.0) * 100).round
      end

      def to_s
        %Q[#{@translation}: #{@ore} (#{@density}) => #{@percent}%]
      end
    end

    class Links < Model

      attr_reader :links
      def initialize(lines:, links_index:)
        tokens = ResponseParser.tokenize_line(line: lines[links_index])
        hash = TFClient::ResponseParser.label_and_translation(tokens: tokens)
        super(label: hash[:label], translation: hash[:translation] )

        items = ResponseParser.collect_list_items(lines: lines, start_index: links_index + 1)
        @links = items.map do |item|
          tokens = ResponseParser.tokenize_line(line: item.strip)
          index = TFClient::ResponseParser.nth_value_from_end(tokens: tokens, n: 1).to_i
          drag = TFClient::ResponseParser.nth_value_from_end(tokens: tokens, n: 0).to_i
          # direction is WIP
          direction = LINK_MAP[index.to_s]
          {
            index: index, drag: drag, direction: direction,
            string: %Q[[#{index}] drag: #{drag} => #{direction}]
          }
        end
      end

      def to_s
        "#{@translation}: #{@links.map {|link| link[:string]}}"
      end
    end
  end
end
