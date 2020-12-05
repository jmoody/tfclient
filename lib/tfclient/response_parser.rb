
module TFClient
  class ResponseParser

    FIELD_DELIMITER = "|".freeze

    def self.is_list_item?(line:)
      if line && line.length != 0 && line.start_with?("\t")
        true
      else
        false
      end
    end

    def self.collect_list_items(lines:, start_index:)
      items = []
      index = start_index
      loop do
        line = lines[index]
        if self.is_list_item?(line: line)
          items << line.strip
          index = index + 1
        else
          break
        end
      end
      items
    end

    def self.tokenize_line(line:)
      lines = line.split(FIELD_DELIMITER)
      stripped = []
      lines.each_with_index do |line, index|
        if index == 0
          stripped << line
        else
          stripped << line.strip
        end
      end
      stripped
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
      response << Coordinate.new(tokens: ResponseParser.tokenize_line(line: nav[0])).to_s
      response << Brightness.new(tokens: ResponseParser.tokenize_line(line: nav[1])).to_s
      response << Asteroids.new(tokens: ResponseParser.tokenize_line(line: nav[2])).to_s
      response << Links.new(lines: lines, links_index: 3)
    end
  end
end