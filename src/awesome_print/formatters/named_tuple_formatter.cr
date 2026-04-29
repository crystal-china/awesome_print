module AwesomePrint
  module Formatters
    class NamedTupleFormatter(T) < BaseFormatter
      getter named_tuple : T

      def initialize(@named_tuple : T, inspector : Inspector)
        super(inspector)
      end

      def format : String
        return "{}" if named_tuple.empty?

        if inspector.multiline
          multiline_named_tuple
        else
          "{ #{printable_entries.join(", ")} }"
        end
      end

      private def multiline_named_tuple : String
        data = printable_entries

        if should_be_limited?
          data = limited(data, left_width(printable_keys), true)
          separator_index = get_limit_size // 2
          data[separator_index] = "#{indent(inspector.indent_size)}#{data[separator_index]}"
        end

        "{\n#{data.join(",\n")}\n#{outdent}}"
      end

      private def printable_entries : Array(String)
        keys = printable_keys
        width = left_width(keys)

        named_tuple.to_a.sort_by(&.[0].to_s).map do |key, value|
          key_string = colorize("#{key}:", :symbol)
          indented do
            "#{align(key_string, width)} #{inspector.awesome(value)}"
          end
        end
      end

      private def printable_keys
        named_tuple.keys.to_a.map do |key|
          colorize("#{key}:", :symbol)
        end.sort
      end

      private def left_width(keys) : Int32
        width = keys.max_of { |entry| colorless_size(entry) }
        width + inspector.indent_size.abs
      end
    end
  end
end
