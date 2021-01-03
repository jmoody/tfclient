
module TFClient::Models::Server
  class Status < Response

    attr_reader :states
    attr_reader :status_report
    attr_reader :mass, :total_outfit_space, :used_outfit_space
    attr_reader :heat, :max_heat, :heat_rate, :cooling_status
    attr_reader :energy, :max_energy, :energy_rate, :power_status
    attr_reader :antigravity_engine_status, :antigravity
    attr_reader :mining_status, :mining_interval, :mining_power
    attr_reader :engine_status, :warp_charge
    attr_reader :shield_status, :shield_max, :shield, :shield_charge_rate
    attr_reader :colonists, :colonists_status

    def initialize(lines:)
      super(lines: lines)

      @states = {}

      @status_report = StatusReport.new(lines: lines)
      @mass = @status_report.hash[:mass].to_i
      @total_outfit_space = @status_report.hash[:total_outfit_space].to_i

      outfit_space_line = lines.detect do |line|
        line.strip.start_with?("Outfit space")
      end

      hash = hash_from_line_values(line: outfit_space_line)
      @used_outfit_space = @total_outfit_space - hash[:space].to_i

      # Cooling
      @states[:cooling], @cooling_status = status_from_lines(
        lines: lines,
        start_with: "Cooling status")
      @heat = @status_report.hash[:heat].to_i
      @max_heat = @status_report.hash[:max_heat].to_i
      @heat_rate = @status_report.hash[:heat_rate].to_f

      # Energy / Power
      @states[:power], @power_status = status_from_lines(
        lines: lines,
        start_with: "Power status"
      )

      @energy = @status_report.hash[:energy].to_i
      @max_energy = @status_report.hash[:max_energy].to_i
      @energy_rate = @status_report.hash[:energy_rate].to_f

      # Antigravity
      antigravity_line = lines.detect do |line|
        line.strip.start_with?("Antigravity engines")
      end

      if antigravity_line
        @states[:antigravity], @antigravity_engine_status =
          status_from_lines(lines: lines, start_with: "Antigravity engines")
        @antigravity = @status_report.hash[:antigravity].to_i
      else
        # Needs translation
        @states[:antigravity] = "Offline"
        @antigravity = "Antigravity engines: Offline"
      end

      # Mining
      mining_progress_line = lines.detect do |line|
        line.strip.start_with?("Mining progress")
      end

      if mining_progress_line
        @states[:mining], @mining_status =
          status_from_lines(lines: lines,
                            start_with: "Mining progress")
        hash = hash_from_line_values(line: mining_progress_line)
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
      warp_line = lines.detect do |line|
        line.strip.start_with?("Warp engines")
      end
      if warp_line
        @states[:warp], @engine_status =
          status_from_lines(lines: lines,
                            start_with: "Warp engines")
        @warp_charge = @status_report.hash[:warp_charge].to_f
      else
        @states[:warp] = "Offline"
        @warp_charge = 0.0
      end

      # Shield
      shield_status_line = lines.detect do |line|
        line.strip.start_with?("Shields")
      end

      if shield_status_line
        @states[:shields], @shield_status =
          status_from_lines(lines: lines,
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
        @shield = 0
      end

      # Colonists
      colonists_line = lines.detect do |line|
        line.strip.start_with?("Colonists")
      end

      if colonists_line
        # TODO Need translation
        @states[:colonists] = "Crewed"
        @colonists_status = substitute_line_values(line: colonists_line)
        hash = hash_from_line_values(line: colonists_line)
        @colonists = hash[:crew].to_i
      else
        # TODO Need translation
        @states[:colonists] = "Unmanned"
        @colonists_status = "Unmanned"
        @colonists = 0
      end
    end

    def system_id
      @status_report.hash[:sys_id]
    end
  end
end