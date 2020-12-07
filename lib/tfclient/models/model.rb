
module TFClient
  module Models
    class Model
      attr_accessor :label, :translation
      def initialize(label:, translation:)
        @label = label
        @translation = translation
      end
    end

    class ModelWithItems < Model
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
