module AwesomePrint
  module Formatters
    class TupleFormatter(T) < BaseFormatter
      getter tuple : T

      def initialize(@tuple : T, inspector : Inspector)
        super(inspector)
      end

      def format : String
        values = tuple.to_a
        return colorize("{}", :hash) if values.empty?

        if inspector.multiline
          multiline_tuple(values)
        else
          "#{colorize("{", :hash)} #{values.map { |item| inspector.awesome(item) }.join(", ")} #{colorize("}", :hash)}"
        end
      end

      private def multiline_tuple(values : Array) : String
        data = values.map_with_index do |item, index|
          indented do
            "#{indent}#{colorize("[#{index.to_s.rjust(width(values))}] ", :array)}#{inspector.awesome(item)}"
          end
        end

        if should_be_limited?
          data = limited(data, width(values))
          separator_index = get_limit_size // 2
          data[separator_index] = "#{indent(inspector.indent_size)}#{data[separator_index]}"
        end

        "#{colorize("{", :hash)}\n#{data.join(",\n")}\n#{indent}#{colorize("}", :hash)}"
      end

      private def width(values : Array) : Int32
        (values.size - 1).to_s.size
      end
    end
  end
end
