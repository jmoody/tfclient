
module TFClient
  class ResponseParser

    FIELD_DELIMITER = "|".freeze
    VARIABLE_REGEX = /(\{[a-z_]+\}+)/.freeze

    def self.substitute_line_values(line:)
      return line.chomp if !line[/\|/]
      tokens = line.chomp.split("|")

      translation = tokens[1]

      matches = translation.scan(VARIABLE_REGEX)

      return translation  if matches.empty?

      values = self.hash_from_line_values(line: line.chomp)

      with_substitutes = translation.chomp

      matches.each do |match|
        key = match[0].sub("{", "").sub("}", "").to_sym
        with_substitutes.gsub!(match[0], values[key])
      end

      with_substitutes
    end

    def self.substitute_values(lines:)
      lines.map do |line|
        self.substitute_line_values(line:line.chomp)
      end
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
    attr_reader :textflight_command
    attr_reader :response
    attr_reader :lines

    def initialize(command:, textflight_command:, response:)
      @command = command
      @textflight_command = textflight_command
      @response = response
    end

    def parse
      @lines = @response.lines(chomp: true).reject { |line| line.length == 0 }
      case @textflight_command
      when "nav"
        parse_nav
      when "scan"
        parse_scan
      when "status"
        parse_status
      else
        if @response[/#{Models::STATUS_BEGIN}/]
          @response = @lines[0].chomp
          @lines = [@response]
        end

        puts ResponseParser.substitute_values(lines: @lines).join("\n")
      end
    end

    def parse_nav
      nav = TFClient::Models::Nav.new(lines: lines)
      puts nav.response
    end

    def parse_scan
      scan = TFClient::Models::Scan.new(lines: lines)
      puts scan.response
    end

    def parse_status
      _, index_start =
        ResponseParser.line_and_index_for_beginning_with(
          lines: @lines,
          string: Models::STATUS_BEGIN
        )
      if index_start == -1
        puts ResponseParser.substitute_values(lines: @lines).join("\n")
      end

      _, index_end =
        ResponseParser.line_and_index_for_beginning_with(
          lines: @lines,
          string: Models::STATUS_END
        )

      if index_start != 0
        lines_before_status = @lines[0..index_start - 1]
        puts ResponseParser.substitute_values(
          lines: lines_before_status
        ).join("\n")
      else
        lines_after_status = @lines[index_end + 1..-1]
        puts ResponseParser.substitute_values(
          lines: lines_after_status
        ).join("\n")
      end
    end
  end
end