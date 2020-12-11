
module TFClient
  class ResponseParser

    FIELD_DELIMITER = "|".freeze

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

    # returns two values
    def self.line_and_index_for_beginning_with(lines:, string:)
      lines.each_with_index do |line, index|
        return line.chomp, index if line.start_with?(string)
      end
      return nil, -1
    end

    # Returns a hash of the key=value pairs found at the end of lines
    def self.hash_from_line_values(line:)
      tokens = self.tokenize_line(line: line)[2..-1]
      hash = {}
      tokens.each do |token|
        key_value = token.split("=")
        hash[key_value[0].to_sym] = key_value[1]
      end
      hash
    end

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

    def self.label_and_translation(tokens:)
      if tokens[0][/Claimed by/]
        {label: "Claimed by", translation: tokens[1].split("'")[0].strip}
      else
        {label: tokens[0].split(":")[0], translation: tokens[1].split(":")[0] }
      end
    end

    def self.camel_case_from_string(string:)
      string.split(" ").map do |token|
        token.capitalize
      end.join("")
    end

    def self.snake_case_sym_from_string(string:)
      string.split(" ").map do |token|
        token.downcase
      end.join("_").to_sym
    end

    def self.model_class_from_string(string:)
      if !TFClient::Models.constants.include?(string.to_sym)
        return nil
      end

      "TFClient::Models::#{string}".split("::").reduce(Object) do |obj, cls|
        obj.const_get(cls)
      end
    end

    attr_reader :command
    attr_reader :response
    attr_reader :lines
    def initialize(command:, response:)
      @command = command
      @response = response
    end

    def parse
      @lines = @response.lines(chomp: true).reject { |line| line.length == 0 }
      case command
      when "nav"
        return parse_nav
        else
          return lines.join("\n")
      end
    end

    def parse_nav
      nav = TFClient::Models::Nav.new(lines: lines)

      puts nav.response
    end
  end
end