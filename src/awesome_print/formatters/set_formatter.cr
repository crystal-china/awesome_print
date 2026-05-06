module AwesomePrint
  module Formatters
    class SetFormatter(T) < BaseFormatter
      getter set : Set(T)

      def initialize(@set : Set(T), inspector : Inspector)
        super(inspector)
      end

      def format : String
        return colorize("()", :array) if set.empty?

        values = set.to_a
        if inspector.multiline
          multiline_set(values)
        else
          "#{colorize("(", :array)} #{inline_values(values).join(", ")} #{colorize(")", :array)}"
        end
      end

      private def multiline_set(values : Array) : String
        data = values.map do |item|
          indented do
            "#{indent}#{inspector.awesome(item)}"
          end
        end

        if should_be_limited?
          data = limited_values(data)
        end

        "#{colorize("(", :array)}\n#{data.join(",\n")}\n#{indent}#{colorize(")", :array)}"
      end
      private def limited_values(data : Array(String)) : Array(String)
        limited_inline_values(data).map_with_index do |value, index|
          value == ".." && index == get_limit_size // 2 ? "#{indent(inspector.indent_size)}.." : value
        end
      end

      private def inline_values(values : Array) : Array(String)
        limited_inline_values(values.map { |item| inspector.awesome(item) })
      end
    end
  end
end
