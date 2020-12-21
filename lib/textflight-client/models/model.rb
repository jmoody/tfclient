
module TFClient
  module Models
    require "cousin_roman"

    TABLE_OPTIONS = { padding: [0,1,0,1], width: 80, resize: true }

    class Response
      attr_accessor :lines, :response

      def initialize(lines:)
        @lines = lines.dup
        @response = []
      end
    end

    class Model
      attr_accessor :label, :translation, :values_hash

      def initialize(line:)
        tokens = ResponseParser.tokenize_line(line: line)
        tokens_hash = ResponseParser.label_and_translation(tokens: tokens)
        @label = tokens_hash[:label]
        @translation = tokens_hash[:translation]
        @values_hash = ResponseParser.hash_from_line_values(line: line)
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
end
