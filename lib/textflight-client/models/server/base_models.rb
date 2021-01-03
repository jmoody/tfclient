
module TFClient
  module Models
    module Server
      require "cousin_roman"

      STATUS_BEGIN = "STATUSREPORT BEGIN".freeze
      STATUS_END = "STATUSREPORT END".freeze

    end
  end
end

module TFClient::Models::Server::Parser
  FIELD_DELIMITER = "|".freeze
  VARIABLE_REGEX = /({[a-z_]+}+)/.freeze

  def substitute_line_values(line:)
    return line.chomp if !line[/\|/]
    tokens = line.chomp.split("|")

    translation = tokens[1]

    matches = translation.scan(VARIABLE_REGEX)

    return translation  if matches.empty?

    values = hash_from_line_values(line: line.chomp)

    with_substitutes = translation.chomp

    matches.each do |match|
      key = match[0].sub("{", "").sub("}", "").to_sym
      with_substitutes.gsub!(match[0], values[key])
    end

    with_substitutes
  end

  def substitute_values(lines:)
    lines.map do |line|
      substitute_line_values(line:line.chomp)
    end
  end

  def tokenize_line(line:)
    lines = line.split(FIELD_DELIMITER)
    stripped = []
    lines.each_with_index do |elm, index|
      if index == 0
        stripped << elm
      else
        stripped << elm.strip
      end
    end
    stripped
  end

  # returns two values
  def line_and_index_for_beginning_with(lines:, string:)
    lines.each_with_index do |line, index|
      return line.chomp, index if line.start_with?(string)
    end
    #noinspection RubyUnnecessaryReturnStatement
    return nil, -1
  end

  # Returns a hash of the key=value pairs found at the end of lines
  def hash_from_line_values(line:)
    tokens = tokenize_line(line: line)[2..-1]
    hash = {}
    tokens.each do |token|
      key_value = token.split("=")
      hash[key_value[0].to_sym] = key_value[1]
    end
    hash
  end

  def is_list_item?(line:)
    if line && line.length != 0 && line.start_with?("\t")
      true
    else
      false
    end
  end

  def collect_list_items(lines:, start_index:)
    items = []
    index = start_index
    loop do
      line = lines[index]
      if is_list_item?(line: line)
        items << line.strip
        index = index + 1
      else
        break
      end
    end
    items
  end

  def label_and_translation(tokens:)
    if tokens[0][/Claimed by/]
      {label: "Claimed by", translation: tokens[1].split("'")[0].strip}
    else
      {label: tokens[0].split(":")[0], translation: tokens[1].split(":")[0] }
    end
  end

  def camel_case_from_string(string:)
    string.split(" ").map do |token|
      token.capitalize
    end.join("")
  end

  def snake_case_sym_from_string(string:)
    string.split(" ").map do |token|
      token.downcase
    end.join("_").to_sym
  end

  def model_class_from_string(string:)
    if !TFClient::Models::Server.constants.include?(string.to_sym)
      return nil
    end

    "TFClient::Models::Server::#{string}".split("::").reduce(Object) do |obj, cls|
      obj.const_get(cls)
    end
  end

  def status_from_lines(lines:, start_with:)
    stripped = lines.map { |line| line.strip }
    prefix = start_with.strip
    line, _ = line_and_index_for_beginning_with(lines: stripped,
                                                string: prefix)
    if !lines || !line.start_with?(prefix)
      raise "expected line to be a status line for #{prefix} in #{lines}"
    end

    tokens = tokenize_line(line: line)

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
    else
      # nop
    end

    translation = tokens[1]

    return status, translation if tokens.size == 2

    translation = substitute_line_values(line: line)

    #noinspection RubyUnnecessaryReturnStatement
    return status, translation.strip
  end

  def self.process_status_report_response(lines:)
    parser = Class.new do
      include TFClient::Models::Server::Parser
      def to_s; inspect; end
      def inspect; "#<Anonymous Parser>"; end
    end.new

    lines_to_print = []
    _, index_start =
      parser.line_and_index_for_beginning_with(
        lines: lines,
        string: TFClient::Models::Server::STATUS_BEGIN
      )

    if index_start == -1
      lines_to_print = lines_to_print + parser.substitute_values(lines: lines)
    end

    _, index_end =
      parser.line_and_index_for_beginning_with(
        lines: lines,
        string: TFClient::Models::Server::STATUS_END
      )

    if index_start != 0
      lines_before_status = lines[0..index_start - 1]
      lines_to_print = lines_to_print + parser.substitute_values(
        lines: lines_before_status
      )
      return lines_to_print, nil
    else
      lines_after_status = lines[index_end + 1..-1]
      lines_to_print = lines_to_print + parser.substitute_values(
        lines: lines_after_status
      )
      return lines_to_print, lines[index_start...index_end]
    end
  end
end

module TFClient::Models::Server

  TABLE_OPTIONS = { padding: [0,1,0,1], width: 80, resize: true }

  class Response
    include TFClient::Models::Server::Parser

    attr_accessor :lines, :response

    def initialize(lines:)
      @lines = lines.dup
      @response = []
    end
  end

  class Model
    include TFClient::Models::Server::Parser

    attr_accessor :label, :translation, :values_hash

    def initialize(line:)
      tokens = tokenize_line(line: line)
      tokens_hash = label_and_translation(
        tokens: tokens
      )
      @label = tokens_hash[:label]
      @translation = tokens_hash[:translation]
      @values_hash = hash_from_line_values(line: line)
    end
  end

  class ModelWithItems < Model
    require "tty-table"

    attr_reader :items

    def count
      @items.count
    end

    def to_s
      "#{@translation}: #{@items.map { |item| item[:string]}}"
    end

    def items_to_s
      @items.map { |item| "\t#{item[:string]}" }
    end

    def response_str
      "#{@translation}:\n#{items_to_s.join("\n")}"
    end

    def lines_offset
      @items.length + 1
    end
  end
end
