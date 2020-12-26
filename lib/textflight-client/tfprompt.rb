
module TFClient
  class TFPrompt

    attr_reader :status_report
    attr_reader :operator
    attr_accessor :mass, :warp_charge, :x, :y, :shield_charge
    attr_accessor :system_id

    def initialize(operator:, status_report:)
      @operator = operator
      @status_report = status_report
      @mass = status_report.hash[:mass].to_i
      @warp_charge = status_report.hash[:warp_charge]
      @shield_charge = status_report.hash[:shield]
      @system_id = status_report.hash[:sys_id]
    end

    def to_s
      "S: #{shield_percent}% Ms: #{@mass} Wrp: #{warp_percent}% (#{@x},#{@y}) #{operator} > "
    end

    def warp_percent
      ((@warp_charge.to_f/@mass.to_i) * 100).to_i
    end

    def shield_percent
      ((@shield_charge.to_f/@mass.to_i) * 100).to_i
    end
  end
end