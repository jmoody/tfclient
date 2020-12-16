
module TFClient
  module Models

    class Status < Response

      LINE_IDENTIFIERS = [
        "Stability",
        "Fuel",
        "Shields",
        "Warp engines",
        "Antigravity engines",
        "Mining progress",
        "Colonists"
      ]

      attr_reader :mass, :total_outfit_space, :used_outfit_space
      attr_reader :heat, :max_heat, :heat_rate, :cooling_status
      attr_reader :energy, :max_energy, :energy_rate, :power_status
      attr_reader :antigravity_engine_status
      attr_reader :mining_progress, :mining_interval
      attr_reader :engine_status, :engine_charge
      attr_reader :shield_status, :shield_power, :shield_percent, :shield_charge_rate
      attr_reader :colonists
      attr_reader :translations

      def initialize(lines:)
        super(lines: lines)

        LINE_IDENTIFIER.each_with_index do |label, label_index|
          var_name = ResponseParser.snake_case_sym_from_string(string: label)
          class_name = ResponseParser.camel_case_from_string(string: label)

          clazz = ResponseParser.model_class_from_string(string: class_name)
          if clazz.nil?
            raise "could not find class name: #{class_name}"
          end

          line, _ = ResponseParser.line_and_index_for_beginning_with(lines: @lines,
                                                                     string: label)

          next if line.nil?

          if label_index < 4
            var = clazz.new(line: line)
          else
            var = clazz.new(lines: @lines)
          end

          instance_variable_set("@#{var_name}", var)
        end
      end
    end

    class General < ModelWithItems

      attr_reader :mass, :total_outfit_space, :used_outfit_space
      attr_reader :heat, :max_heat, :energy, :max_energy

      def initialize(lines:)
      line, index = ResponseParser.line_and_index_for_beginning_with(lines: lines,
                                                                     string: "General")
      super(line: line)

      items = ResponseParser.collect_list_items(lines: lines, start_index: index + 1)
      @items = items.map do |item|
        line = item.strip

        identifier = ResponseParser.tokenize_line(line: line)[0].split(":")[0]

        hash = ResponseParser.hash_from_line_values(line: line)

        case identifier
        when "Mass"
          @mass = hash[:mass].to_i
        when "Outfit space"
          @out
        when "Heat"
        when "Energy"
        else
          raise "Unexpected identifier: #{identifier}"
        end






        mass = hash[:mass].to_i
        out = hash[:name]
        count = hash[:count].to_i
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
  end
end
