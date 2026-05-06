module AwesomePrint
  module Formatters
    class NamedTupleFormatter(T) < BaseFormatter
      getter named_tuple : T

      def initialize(@named_tuple : T, inspector : Inspector)
        super(inspector)
      end

      def format : String
        return colorize("{}", :array) if named_tuple.empty?

        if inspector.multiline
          multiline_named_tuple
        else
          "#{colorize("{", :array)} #{limited_inline_values(printable_entries).join(", ")} #{colorize("}", :array)}"
        end
      end

      private def multiline_named_tuple : String
        data = printable_entries

        if should_be_limited?
          data = limited(data, left_width(printable_keys), true)
          separator_index = get_limit_size // 2
          data[separator_index] = "#{indent(inspector.indent_size)}#{data[separator_index]}"
        end

        "#{colorize("{", :array)}\n#{data.join(",\n")}\n#{indent}#{colorize("}", :array)}"
      end

      private def printable_entries : Array(String)
        keys = printable_keys
        width = left_width(keys)

        entries = named_tuple.to_a
        entries = entries.sort_by(&.[0].to_s) if inspector.order.sorted?

        entries.map do |key, value|
          key_string = colorize("#{key}:", :symbol)
          indented do
            "#{align(key_string, width)} #{inspector.awesome(value)}"
          end
        end
      end

      private def printable_keys
        keys = named_tuple.keys.to_a
        keys = keys.sort if inspector.order.sorted?

        keys.map do |key|
          colorize("#{key}:", :symbol)
        end
      end

      private def left_width(keys) : Int32
        width = keys.max_of { |entry| colorless_size(entry) }
        width + inspector.indent_size.abs
      end
    end
  end
end
