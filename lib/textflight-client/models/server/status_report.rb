
module TFClient::Models::Server

  class StatusReport

    attr_reader :hash

    def initialize(lines:)
      if lines[0] != STATUS_BEGIN
        raise "Expected lines[0] to be == #{STATUS_BEGIN}, found: #{lines[0]}"
      end

      @hash = {}
      lines.each do |line|
        break if line == STATUS_END
        tokens = line.strip.split(": ")
        @hash[tokens[0].to_sym] = tokens[1]
      end
    end
  end
end