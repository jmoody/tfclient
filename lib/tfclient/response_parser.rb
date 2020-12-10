
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
    # TODO unused?
    def self.tokens_and_index_for_label(lines:, label:)
      lines.each_with_index do |line, index|
        if line.start_with?(label)
          return self.tokenize_line(line: line.chomp), index
        end
      end
      return nil, -1
    end

    # returns two values
    def self.line_and_index_for_label(lines:, label:)
      lines.each_with_index do |line, index|
        return line.chomp, index if line[/#{label}/]
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

    # TODO needed?
    def self.index_of_label(lines:, label:)
      lines.each_with_index do |line, index|
        return index if line[/#{label}/]
      end
      nil
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

    def self.nth_value_from_end(tokens:, n:)
      tokens[tokens.length - (n + 1)].split("=")[1]
    end

    def self.model_class_from_label(label:)
      if !TFClient::Models.constants.include?(label.to_sym)
        return nil
      end

      "TFClient::Models::#{label}".split("::").reduce(Object) do |obj, cls|
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
      TFClient::Models::Nav.new(lines: lines)

      #coordinate = Models::Coordinates.new(tokens: tokens
      # hash = {
      #   coordinate: Models::Coordinates.new(tokens: ResponseParser.tokenize_line(line: @lines[0])),
      #   brightness: Models::Brightness.new(tokens: ResponseParser.tokenize_line(line: @lines[1])),
      #   asteroids: Models::Asteroids.new(tokens: ResponseParser.tokenize_line(line: @lines[2]))
      # }
      # hash[:links] = Models::Links.new(lines: @lines, start_index: 3)
      # hash[:planets] = Models::Planets.new(lines: @lines, start_index: hash[:links].lines_offset + 3)
      # hash[:structures] = Models::Structures.new(lines: @lines,
      #                                            start_index: 3 +
      #                                              hash[:links].lines_offset +
      #                                              hash[:planets].lines_offset )
      # response = []
      # response << hash[:coordinate].to_s
      # response << hash[:brightness].to_s
      # response << hash[:asteroids].to_s
      # response << hash[:links].response_str
      # response << hash[:planets].response_str
      # response << hash[:structures].response_str
      #
      # hash[:response] = response.join("\n")
      # hash
      hash
    end
  end
end