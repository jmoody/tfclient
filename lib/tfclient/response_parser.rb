
module TFClient
  class ResponseParser

    FIELD_DELIMITER = "|".freeze

    def self.tokenize_line(line:)
      tokens = line.strip.split(FIELD_DELIMITER)
      tokens.map { |token| token.strip }
    end

    def self.label_and_translation(tokens:)
      {label: tokens[0].split(":")[0], translation: tokens[1].split(":")[0] }
    end

    def self.nth_value_from_end(tokens:, n:)
      tokens[tokens.length - (n + 1)].split("=")[1]
    end

    attr_reader :command
    attr_reader :response
    def initialize(command:, response:)
      @command = command
      @response = response
    end

    def parse
      lines = response.lines(chomp: true).reject { |line| line.length == 0 }
      case command
      when "nav"
        parse_nav(lines)
      end
    end

    def parse_nav(lines:)
      nav = lines.dup
      response = []
      response << Coordinate.new(ResponseParser.tokenize_line(line: nav[0])).to_s
      response << Brightness.new(ResponseParser.tokenize_line(line: nav[1])).to_s
      response << Asteroids.new(ResponseParser.tokenize_line(line: nav[2])).to_s
    end
  end
end