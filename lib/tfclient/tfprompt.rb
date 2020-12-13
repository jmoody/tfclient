
module TFClient
  class TFPrompt

    attr_reader :status_report

    attr_writer :mass, :warp_charge, :x, :y

    def initialize(status_report:)
      @status_report = status_report
      @mass = status_report.hash[:mass].to_i
      @warp_charge = status_report.hash[:warp_charge].to_i
    end

    def to_s
      "Ms: #{@mass} Wrp: #{warp_percent}% (#{@x},#{@y}) > "
    end

    def warp_percent
      ((@warp_charge/@mass.to_f) * 100).to_i
    end
  end
end