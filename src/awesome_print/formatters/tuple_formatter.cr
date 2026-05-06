module AwesomePrint
  module Formatters
    class TupleFormatter(T) < BaseFormatter
      getter tuple : T

      def initialize(@tuple : T, inspector : Inspector)
        super(inspector)
      end

      def format : String
        values = tuple.to_a
        return colorize("{}", :array) if values.empty?

        if inspector.multiline
          multiline_tuple(values)
        else
          "#{colorize("{", :array)} #{inline_values(values).join(", ")} #{colorize("}", :array)}"
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

        "#{colorize("{", :array)}\n#{data.join(",\n")}\n#{indent}#{colorize("}", :array)}"
      end

      private def width(values : Array) : Int32
        (values.size - 1).to_s.size
      end

      private def inline_values(values : Array) : Array(String)
        limited_inline_values(values.map { |item| inspector.awesome(item) })
      end
    end
  end
end
