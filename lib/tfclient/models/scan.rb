
module TFClient
  module Models

    class Scan < Response
      LINE_IDENTIFIERS = [
        "Owner",
        #"Operators",
        "Outfit space",
        "Shield charge",
        #"Outfits",
        #"Cargo"
      ]

      attr_reader :id, :name

      def initialize(lines:)
        super(lines: lines)

        ship_line = lines[0]
        values_hash = ResponseParser.hash_from_line_values(line: ship_line)
        @id = values_hash[:id].to_i
        @name = values_hash[:name]

        LINE_IDENTIFIERS.each do |line_id|

          # Not sure what value this adds
          next if line_id == "Operators"

          var_name = ResponseParser.snake_case_sym_from_string(string: line_id)
          class_name = ResponseParser.camel_case_from_string(string: line_id)
          clazz = ResponseParser.model_class_from_string(string: class_name)

          if clazz.nil?
            raise "could not find class name: #{class_name} derived from #{line_id}"
          end

          line, _ = ResponseParser.line_and_index_for_beginning_with(lines: @lines,
                                                                     string: line_id)

          if ["Owner", "Outfit space", "Shield charge"].include?(line_id)
            var = clazz.new(line: line)
          elsif ["Operators", "Outfits", "Cargo"].include?(line_id)
            var = clazz.new(lines: @lines)
          else
            raise "Cannot find class initializer for: #{line_id}"
          end

          instance_variable_set("@#{var_name}", var)
          @response << var.to_s
        end
      end
    end

    class Owner < Model
      attr_reader :username

      def initialize(line:)
        super(line: line)
        @username = @values_hash[:username]
      end

      def to_s
        "#{@translation}: #{@username}"
      end
    end

    class OutfitSpace < Model
      attr_reader :value

      def initialize(line:)
        super(line: line)
        @value = @values_hash[:space].to_i
      end

      def to_s
        "#{@translation}: #{@value}"
      end
    end

    class ShieldCharge < Model
      attr_reader :value

      def initialize(line:)
        super(line: line)
        @value = @values_hash[:charge].to_f
      end

      def to_s
        "#{@translation}: #{@value}"
      end
    end

    class Outfits < Model
      attr_reader :value

      def initialize(line:)
        super(line: line)
      end

      def to_s
        "#{@translation}"
      end

    end

    class Cargo < Model
      attr_reader :value

      def initialize(line:)
        super(line: line)
      end

      def to_s
        "#{@translation}:"
      end
    end
  end
end

