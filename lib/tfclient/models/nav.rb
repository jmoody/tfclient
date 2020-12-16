
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
          #@response << var.to_s
        end
      end

      def response
        puts @planets

        puts @links
        table = TTY::Table.new(rows: [[
          "#{@brightness.to_s}",
          "#{@asteroids.to_s}",
          "#{@coordinates}"]
        ])

        puts table.render(:ascii, Models::TABLE_OPTIONS) do |renderer|
          renderer.alignments= [:left, :center, :right]
        end

        puts @structures
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
            index: index, drag: drag, direction: direction, faction: faction
          }
        end.sort do |a, b|
          Nav::COMPASS_ORDER[a[:direction]] <=> Nav::COMPASS_ORDER[b[:direction]]
        end
      end

      def to_s
        table = TTY::Table.new(header: [
          {value: "#{@translation}", alignment: :right},
          {value: "drag", alignment: :center},
          {value: "faction", alignment: :center},
          {value: "original", alignment: :center},
          {value: "direction", alignment: :center}
        ])

        @items.each do |item|
          table << [
            "#{item[:direction]}",
            item[:drag],
            item[:faction],
            "[#{item[:index]}]",
            "#{item[:direction]}"
          ]
        end

        table.render(:ascii, Models::TABLE_OPTIONS) do |renderer|
          renderer.alignments= [:right, :right, :center, :center, :center, :center]
        end
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

          { index: index, type: type, name: name, faction: faction }
        end
      end

      def to_s
        return "" if @items.empty?
        table = TTY::Table.new(header: [
          {value: "#{@translation}", alignment: :right},
          {value: "type", alignment: :center},
          {value: "name", alignment: :center},
          {value: "faction", alignment: :center},
          {value: "index", alignment: :center}
        ])

        @items.each do |item|
          table << [
            "[#{item[:index]}]",
            item[:type],
            item[:name],
            item[:faction],
            "[#{item[:index]}]"
          ]
        end

        table.render(:ascii, Models::TABLE_OPTIONS) do |renderer|
          renderer.alignments= [:right, :right, :center, :center, :center]
        end
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
          # TODO: distinguish shipyards from bases
          type = hash[:sclass] || "base"
          { id: id, name: name, type: type }
        end
      end

      def to_s
        table = TTY::Table.new(header: [
          {value: "#{@translation}", alignment: :right},
          {value: "name", alignment: :center},
          {value: "ship class", alignment: :center},
          {value: "id", alignment: :center }
        ])

        @items.each do |item|
          table << ["[#{item[:id]}]", item[:name], item[:type], "[#{item[:id]}]"]
        end

        table.render(:ascii, Models::TABLE_OPTIONS) do |renderer|
          renderer.alignments= [:right, :right, :center, :center]
        end
      end
    end
  end
end
