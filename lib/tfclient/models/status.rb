
module TFClient
  module Models

    class Status < Response

      def self.cooling_status_from_line(line:)
        stripped = line.strip
        if !stripped.start_with?("Cooling status:")
          raise "expected line to be a cooling status line, found: #{line}"
        end

        tokens = ResponseParser.tokenize_line(line: stripped)

        if tokens.size == 2 || tokens.size == 3
          translation = tokens[1].strip.split(": ")[1]

          return translation if tokens.size == 2

          translation = ResponseParser.substitute_line_values(line: stripped)
          translation.split(": ")[1]
        end
      end

      LINE_IDENTIFIERS = [
        "Stability",
        "Fuel",
        "Shields",
        "Warp engines",
        "Antigravity engines",
        "Mining progress",
        "Colonists"
      ]

      attr_reader :status_report
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

        @status_report = Models::StatusReport.new(lines: lines)
        @mass = @status_report.hash[:mass].to_i
        @total_outfit_space = @status_report.hash[:total_outfit_space].to_i

        # 	Outfit space: {space}/{total}|  Outfit space: {space}/{total}|space=0|total=8

        outfit_space_line = lines.detect do |line|
          line.strip.start_with?("Outfit space")
        end

        hash = ResponseParser.hash_from_line_values(line: outfit_space_line)
        @used_outfit_space = @total_outfit_space - hash[:space].to_i

        @heat = @status_report.hash[:heat].to_i
        @max_heat = @status_report.hash[:max_heat].to_i
        @heat_rate = @status_report.hash[:heat_rate].to_f

        cooling_space_line = lines.detect do |line|
          line.strip.start_with?("Cooling status")
        end

        hash = ResponseParser.hash_from_line_values(line: outfit_space_line)




        # LINE_IDENTIFIER.each_with_index do |label, label_index|
        #   var_name = ResponseParser.snake_case_sym_from_string(string: label)
        #   class_name = ResponseParser.camel_case_from_string(string: label)
        #
        #   clazz = ResponseParser.model_class_from_string(string: class_name)
        #   if clazz.nil?
        #     raise "could not find class name: #{class_name}"
        #   end
        #
        #   line, _ = ResponseParser.line_and_index_for_beginning_with(lines: @lines,
        #                                                              string: label)
        #
        #   next if line.nil?
        #
        #   if label_index < 4
        #     var = clazz.new(line: line)
        #   else
        #     var = clazz.new(lines: @lines)
        #   end
        #
        #   instance_variable_set("@#{var_name}", var)
        # end
      end
    end
  end
end
