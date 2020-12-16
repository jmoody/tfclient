
module TFClient
  module Models

    class Status < Response

      def self.status_from_lines(lines:, start_with:)
        stripped = lines.map { |line| line.strip }
        prefix = start_with.strip
        line, _ = ResponseParser.line_and_index_for_beginning_with(lines: stripped,
                                                                   string: prefix)
        if !line.start_with?(prefix)
          raise "expected line to be a status line for #{prefix} in #{lines}"
        end

        tokens = ResponseParser.tokenize_line(line: line)

        if tokens.size == 2 || tokens.size == 3
          translation = tokens[1]

          return translation if tokens.size == 2

          translation = ResponseParser.substitute_line_values(line: line)
          return translation.split(": ")[1]
        end

        raise "Expected 2 or 3 pipe (|) delimited tokens, but found: #{tokens.size} in line: #{line}"
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

        @cooling_status = Status.status_from_lines(lines: lines,
                                                   start_with: "Cooling status")

        @energy = @status_report.hash[:energy].to_i
        @max_energy = @status_report.hash[:max_energy].to_i
        @energy_rate = @status_report.hash[:energy_rate].to_f

        line, _ = ResponseParser.line_and_index_for_beginning_with(lines: lines,
                                                                   string: "Antigravity engines")

        @antigravity_engine_status = ResponseParser.tokenize_line(line: line)[1]
      end
    end
  end
end
