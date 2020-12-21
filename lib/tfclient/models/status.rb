
module TFClient
  module Models

    class Status < Response

      # returns 2 values
      def self.status_from_lines(lines:, start_with:)
        stripped = lines.map { |line| line.strip }
        prefix = start_with.strip
        line, _ = ResponseParser.line_and_index_for_beginning_with(lines: stripped,
                                                                   string: prefix)
        if !line.start_with?(prefix)
          raise "expected line to be a status line for #{prefix} in #{lines}"
        end

        tokens = ResponseParser.tokenize_line(line: line)

        status = tokens[0].split(": ").last

        case status
        when "Overheat in {remaining} seconds!"
          status = "Overheating"
        when "OVERHEATED"
          status = "Overheated"
        when "Ready to engage"
          status = "Ready"
        when "Charging ({charge}%)"
          status = "Charging"
        when "FAILED"
          status = "Failed"
        when "BROWNOUT"
          status = "Brownout"
        when "OVERLOADED"
          status = "Overloaded"
        when "Brownout in {remaining} seconds!"
          status = "Overloaded"
        when "Regenerating at {rate}/s ({shield}/{max})"
          status = "Regenerating"
        when "{progress}% ({interval} second interval)"
          status = "Online"
        end

        translation = tokens[1]

        return status, translation if tokens.size == 2

        translation = ResponseParser.substitute_line_values(line: line)

        return status, translation.strip
      end

      attr_reader :states
      attr_reader :status_report
      attr_reader :mass, :total_outfit_space, :used_outfit_space
      attr_reader :heat, :max_heat, :heat_rate, :cooling_status
      attr_reader :energy, :max_energy, :energy_rate, :power_status
      attr_reader :antigravity_engine_status, :antigravity
      attr_reader :mining_status, :mining_interval, :mining_power
      attr_reader :engine_status, :engine_charge
      attr_reader :shield_status, :shield_max, :shield, :shield_charge_rate
      attr_reader :colonists, :colonists_status

      def initialize(lines:)
        super(lines: lines)

        @states = {}

        @status_report = Models::StatusReport.new(lines: lines)
        @mass = @status_report.hash[:mass].to_i
        @total_outfit_space = @status_report.hash[:total_outfit_space].to_i

        outfit_space_line = lines.detect do |line|
          line.strip.start_with?("Outfit space")
        end

        hash = ResponseParser.hash_from_line_values(line: outfit_space_line)
        @used_outfit_space = @total_outfit_space - hash[:space].to_i

        # Cooling
        @states[:cooling], @cooling_status = Status.status_from_lines(
          lines: lines,
          start_with: "Cooling status")
        @heat = @status_report.hash[:heat].to_i
        @max_heat = @status_report.hash[:max_heat].to_i
        @heat_rate = @status_report.hash[:heat_rate].to_f

        # Energy / Power
        @states[:power], @power_status = Status.status_from_lines(
          lines: lines,
          start_with: "Power status"
        )

        @energy = @status_report.hash[:energy].to_i
        @max_energy = @status_report.hash[:max_energy].to_i
        @energy_rate = @status_report.hash[:energy_rate].to_f

        # Antigravity
        @states[:antigravity], @antigravity_engine_status =
          Status.status_from_lines(lines: lines, start_with: "Antigravity engines")
        @antigravity = @status_report.hash[:antigravity].to_i


        # Mining
        mining_progress_line = lines.detect do |line|
          line.strip.start_with?("Mining progress")
        end

        if mining_progress_line
          @states[:mining], @mining_status =
            Status.status_from_lines(lines: lines,
                                     start_with: "Mining progress")
          hash = ResponseParser.hash_from_line_values(line: mining_progress_line)
          @mining_interval = hash[:interval].to_f
          @mining_power = @status_report.hash[:mining_power].to_f
        else
          @mining_interval = nil
          @mining_power = nil
          # TODO needs a translation
          @states[:mining] = "Offline"
          @mining_status = "Offline"
        end

        # Warp
        @states[:warp], @engine_status =
          Status.status_from_lines(lines: lines,
                                   start_with: "Warp engines")
        @engine_charge = @status_report.hash[:warp_charge].to_f

        # Shield
        shield_status_line = lines.detect do |line|
          line.strip.start_with?("Shields")
        end

        if shield_status_line
          @states[:shields], @shield_status =
            Status.status_from_lines(lines: lines,
                                     start_with: "Shields")
          @shield_charge_rate = @status_report.hash[:shield_rate].to_f
          @shield_max = @status_report.hash[:max_shield].to_f
          @shield = @status_report.hash[:shield].to_f
        else
          # TODO Need translation
          @shield_status = "Offline"
          @states[:shields] = "Offline"
          @shield_charge_rate = nil
          @shield_max = @status_report.hash[:max_shield].to_f
          @shield = nil
        end

        # Colonists
        colonists_line = lines.detect do |line|
          line.strip.start_with?("Colonists")
        end

        if colonists_line
          # TODO Need translation
          @states[:colonists] = "Crewed"
          @colonists_status =
            ResponseParser.substitute_line_values(line: colonists_line)
          hash = ResponseParser.hash_from_line_values(line: colonists_line)
          @colonists = hash[:crew].to_i
        else
          # TODO Need translation
          @states[:colonists] = "Unmanned"
          @colonists_status = "Unmanned"
          @colonists = 0
        end
      end
    end
  end
end
