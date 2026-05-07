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
          multiline_braced_mapping(printable_entries, left_width(printable_keys))
        else
          singleline_braced_collection(printable_entries)
        end
      end

      private def printable_entries : Array(String)
        keys = printable_keys
        width = left_width(keys)

        entries = named_tuple.to_a
        entries = entries.sort_by(&.[0].to_s) if inspector.order.sorted?

        entries.map do |key, value|
          key_string = format_key(key)
          indented do
            formatted_entry(key_string, value, width)
          end
        end
      end

      private def printable_keys
        keys = named_tuple.keys.to_a
        keys = keys.sort if inspector.order.sorted?

        keys.map do |key|
          format_key(key)
        end
      end

      private def left_width(keys) : Int32
        width = keys.max_of { |entry| colorless_size(entry) }
        width + inspector.indent_size.abs
      end

      private def format_key(key) : String
        case inspector.hash_format
        when .json?
          colorize(key.to_s.inspect, :string)
        when .rocket?
          colorize(key.inspect, :symbol)
        else
          colorize("#{key}:", :symbol)
        end
      end

      private def formatted_entry(key_string : String, value, width : Int32) : String
        case inspector.hash_format
        when .json?
          "#{align(key_string, width)}#{colorize(": ", :hash)}#{inspector.awesome(value)}"
        when .rocket?
          "#{align(key_string, width)}#{colorize(" => ", :hash)}#{inspector.awesome(value)}"
        else
          "#{align(key_string, width)} #{inspector.awesome(value)}"
        end
      end
    end
  end
end
