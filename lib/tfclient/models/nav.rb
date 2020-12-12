
module TFClient
  module Models
    class Nav < Response

      GAME_LINK_TO_COMPASS_MAP = {
        "0" => "sw",
        "1" => "s",
        "2" => "se",
        "3" => "w",
        "4" => "e",
        "5" => "nw",
        "6" => "n",
        "7" => "ne"
      }

      COMPASS_TO_GAME_LINK_MAP = {
        "n" => 6,
        "ne" => 7,
        "e" => 4,
        "se" => 2,
        "s" => 1,
        "sw" => 0,
        "w" => 3,
        "nw" => 5
      }

      COMPASS_ORDER = {
        "n" => 0,
        "ne" => 1,
        "e" => 2,
        "se" => 3,
        "s" => 4,
        "sw" => 5,
        "w" => 6,
        "nw" => 7
      }

      # 7 # 0: 315 degrees, X=-1, Y=-1 (northwest)
      # 0 # 1: 0 degrees, X=0, Y=-1 (north)
      # 1 # 2: 45 degrees, X=1, Y=-1 (northeast)
      # 6 # 3: 270 degrees, X=-1, Y=0 (west)
      # 2 # 4: 90 degrees, X=1, Y=0 (east)
      # 5 # 5: 225 degrees, X=-1, Y=1 (southwest)
      # 4 # 6: 180 degrees, X=0, Y=-1 (south) # bug should be 0,1
      # 3 # 7: 135 degrees, X=1, Y=-1 (southeast) # bug should be 1,1

      LABELS = [
        "Coordinates",
        "Claimed by",
        "Brightness",
        "Asteroids",
        "Links",
        "Planets",
        "Structures"
      ].freeze

      attr_reader :coordinates, :claimed_by, :brightness, :asteroids
      attr_reader :links, :planets, :structures

      def initialize(lines:)
        super(lines: lines)

        LABELS.each_with_index do |label, label_index|
          var_name = ResponseParser.snake_case_sym_from_string(string: label)
          class_name = ResponseParser.camel_case_from_string(string: label)

          clazz = ResponseParser.model_class_from_string(string: class_name)
          if clazz.nil?
            raise "could not find class name: #{class_name}"
          end

          line, _ = ResponseParser.line_and_index_for_beginning_with(lines: @lines,
                                                                     string: label)

          # Claimed by is not always present
          next if line.nil?

          if label_index < 4
            var = clazz.new(line: line)
          else
            var = clazz.new(lines: @lines)
          end

          instance_variable_set("@#{var_name}", var)
          @response << var.to_s
        end
      end

      def to_s
        "#<Nav: #{@coordinates.to_s}>"
      end
    end

    class Coordinates < Model
      attr_reader :x, :y

      def initialize(line:)
        super(line: line)
        @x = @values_hash[:x].to_i
        @y = @values_hash[:y].to_i
      end

      def to_s
        %Q[#{@translation}: (#{@x},#{@y})]
      end
    end

    class ClaimedBy < Model
      attr_reader :faction

      def initialize(line:)
        super(line: line)
        @faction = @values_hash[:faction]
      end

      def to_s
        %Q[#{@translation} '#{@faction}']
      end
    end

    class Brightness < Model
      attr_reader :value, :percent

      def initialize(line:)
        super(line: line)
        @value = @values_hash[:brightness].to_i
        @percent = ((@value/255.0) * 100).round
      end

      def to_s
        %Q[#{@translation}: #{@value} => #{@percent}%]
      end
    end

    class Asteroids < Model
      attr_reader :value, :ore, :density, :percent

      def initialize(line:)
        super(line: line)
        @ore = @values_hash[:asteroid_type]
        @density = @values_hash[:asteroid_density].to_i
        @percent = ((@density/7.0) * 100).round
      end

      def to_s
        %Q[#{@translation}: #{@ore} (#{@density}) => #{@percent}%]
      end
    end

    class Links < ModelWithItems

      def initialize(lines:)
        line, index = ResponseParser.line_and_index_for_beginning_with(lines: lines,
                                                                       string: "Links")
        super(line: line)
        items = ResponseParser.collect_list_items(lines: lines, start_index: index + 1)
        @items = items.map do |item|
          line = item.strip
          hash = ResponseParser.hash_from_line_values(line: line)

          index = hash[:index].to_i
          faction = hash[:faction]
          drag = hash[:link_drag].to_i

          # direction is WIP
          direction = Nav::GAME_LINK_TO_COMPASS_MAP[index.to_s]
          {
            index: index, drag: drag, direction: direction, faction: faction,
            string: %Q[#{direction}\t[#{index}] drag: #{drag}\t#{faction}].strip
          }
        end.sort do |a, b|
          Nav::COMPASS_ORDER[a[:direction]] <=> Nav::COMPASS_ORDER[b[:direction]]
        end
      end

      def to_s
        <<~EOM
          #{@translation}:
          #{@items.map { |item| %Q[\t\t#{item[:string]}]}.join("\n")}
        EOM
      end
    end

    class Planets < ModelWithItems

      def initialize(lines:)
        line, index = ResponseParser.line_and_index_for_beginning_with(lines: lines,
                                                                       string: "Planets")
        super(line: line)

        items = ResponseParser.collect_list_items(lines: lines, start_index: index + 1)
        @items = items.map do |item|
          line = item.strip

          hash = ResponseParser.hash_from_line_values(line: line)

          index = hash[:index].to_i
          type = hash[:planet_type]
          name = hash[:name]
          faction = hash[:faction]

          { index: index, type: type, name: name, faction: faction,
            string: %Q[\t[#{index}] #{type}\t#{name}\t#{faction}].strip }
        end
      end

      def to_s
        <<~EOM
          #{@translation}:
          #{@items.map { |item| %Q[\t#{item[:string]}]}.join("\n")}
        EOM
      end
    end

    class Structures < ModelWithItems

      def initialize(lines:)
        line, index = ResponseParser.line_and_index_for_beginning_with(lines: lines,
                                                                       string: "Structures")
        super(line: line)

        items = ResponseParser.collect_list_items(lines: lines, start_index: index + 1)
        @items = items.map do |item|
          line = item.strip

          hash = ResponseParser.hash_from_line_values(line: line)

          id = hash[:id].to_i
          name = hash[:name]
          type = hash[:sclass]
          { id: id, name: name, type: type, string: %Q[[#{id}]\t#{name} #{type ? type : ""}] }
        end
      end

      def to_s
        <<~EOM
          #{@translation}:
          #{@items.map { |item| %Q[\t#{item[:string]}]}.join("\n")}
        EOM
      end
    end
  end
end
