
module TFClient
  module Models

    class Scan < Response
      LINE_IDENTIFIERS = [
        "Owner",
        "Operators",
        "Outfit space",
        "Shield charge",
        "Outfits",
        "Cargo"
      ]

      attr_reader :id, :name, :owner, :outfit_space, :shield_charge
      attr_reader :outfits, :cargo

      def initialize(lines:)
        super(lines: lines)

        ship_line = lines[0]
        values_hash = ResponseParser.hash_from_line_values(line: ship_line)
        @id = values_hash[:id].to_i
        @name = values_hash[:name]

        LINE_IDENTIFIERS.each do |line_id|

          # Not sure what value this adds
          next if line_id == "Operators"

          var_name = ResponseParser.snake_case_sym_from_string(string: line_id)
          class_name = ResponseParser.camel_case_from_string(string: line_id)
          clazz = ResponseParser.model_class_from_string(string: class_name)

          if clazz.nil?
            raise "could not find class name: #{class_name} derived from #{line_id}"
          end

          line, _ = ResponseParser.line_and_index_for_beginning_with(lines: @lines,
                                                                     string: line_id)

          if ["Owner", "Outfit space", "Shield charge"].include?(line_id)
            var = clazz.new(line: line)
          elsif ["Outfits", "Cargo"].include?(line_id)
            var = clazz.new(lines: @lines)
            if var.is_a?(TFClient::Models::Outfits)
              var.max_slots = @outfit_space.value
            end
          else
            raise "Cannot find class initializer for: #{line_id}"
          end

          instance_variable_set("@#{var_name}", var)
        end
      end

      def response
        # TODO this is interesting only when you scan _other_ structures
        # table = TTY::Table.new(header: [
        #   {value: @owner.translation, alignment: :center},
        #   {value: @outfit_space.translation, alignment: :center},
        #   {value: @shield_charge.translation, alignment: :center}
        # ])
        #
        # table << [@owner.username,
        #           @outfit_space.value,
        #           @shield_charge.value]
        #
        # puts table.render(:ascii, padding: [0,1,0,1],
        #                   width: Models::TABLE_WIDTH, resize: true) do |renderer|
        #   renderer.alignments= [:center, :center, :center]
        # end

        puts @outfits.to_s
        puts @cargo.to_s
      end
    end

    class Owner < Model
      attr_reader :username

      def initialize(line:)
        super(line: line)
        @username = @values_hash[:username]
      end

      def to_s
        "#{@translation}: #{@username}"
      end
    end

    class OutfitSpace < Model
      attr_reader :value

      def initialize(line:)
        super(line: line)
        @value = @values_hash[:space].to_i
      end

      def to_s
        "#{@translation}: #{@value}"
      end
    end

    class ShieldCharge < Model
      attr_reader :value

      def initialize(line:)
        super(line: line)
        @value = @values_hash[:charge].to_f
      end

      def to_s
        "#{@translation}: #{@value}"
      end
    end

    class Outfits < ModelWithItems

      attr_accessor :max_slots

      def initialize(lines:)
        line, index = ResponseParser.line_and_index_for_beginning_with(lines: lines,
                                                                       string: "Outfits")
        super(line: line)

        items = ResponseParser.collect_list_items(lines: lines, start_index: index + 1)
        @items = items.map do |item|
          line = item.strip

          hash = ResponseParser.hash_from_line_values(line: line)

          index = hash[:index].to_i
          name = hash[:name]
          mark = hash[:mark].to_i
          setting = hash[:setting].to_i
          { index: index, name: name, mark: mark, setting: setting}
        end
        @max_slots = 0
      end

      def to_s
        table = TTY::Table.new(header: [
          "#{@translation}: #{slots_used}/#{@max_slots} slots",
          {value: "name", alignment: :center},
          {value: "setting", alignment: :center},
          {value: "index", alignment: :center}
        ])

        @items.each do |item|
          table << [
            "[#{item[:index]}]",
            "#{item[:name]} (#{item[:mark].to_roman})",
            item[:setting],
            "[#{item[:index]}]"
          ]
        end

        table.render(:ascii, Models::TABLE_OPTIONS) do |renderer|
          renderer.alignments= [:right, :right, :center, :center]
        end
      end

      def slots_used
        @items.map { |hash| hash[:mark] }.sum
      end
    end

    class Cargo < ModelWithItems

      def initialize(lines:)
        line, index = ResponseParser.line_and_index_for_beginning_with(lines: lines,
                                                                       string: "Cargo")
        super(line: line)

        items = ResponseParser.collect_list_items(lines: lines, start_index: index + 1)
        @items = items.map do |item|
          line = item.strip

          hash = ResponseParser.hash_from_line_values(line: line)

          index = hash[:index].to_i
          name = hash[:name]
          count = hash[:count].to_i
          # TODO: this must be the mark?
          mark = hash[:extra].to_i
          { index: index, name: name, count: count, mark: mark}
        end
      end

      def to_s
        table = TTY::Table.new(header: [
          "Weight: #{weight}",
          {value: "cargo", alignment: :center},
          {value: "amount", alignment: :center},
          {value: "index", alignment: :center}
        ])

        @items.each do |item|
          name = item[:name]
          mark = item[:mark].to_i
          if mark && (mark != 0)
            name = "#{name} (#{mark.to_roman})"
          end
          table << ["[#{item[:index]}]",
                    name,
                    item[:count],
                    "[#{item[:index]}]"]
        end

        table.render(:ascii, Models::TABLE_OPTIONS) do |renderer|
          renderer.alignments= [:right, :right, :center, :center]
        end
      end

      # TODO: only some items in the inventory contribute to weight
      def weight
        @items.map { |hash| hash[:count] }.sum
      end
    end
  end
end
