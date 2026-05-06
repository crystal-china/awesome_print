module AwesomePrint
  module Formatters
    class HashFormatter(K, V) < BaseFormatter
      getter hash : Hash(K, V)

      def initialize(@hash : Hash(K, V), inspector : Inspector)
        super(inspector)
      end

      def format : String
        return colorize("{}", :array) if hash.empty?

        if inspector.multiline
          multiline_hash
        else
          "#{colorize("{", :array)} #{limited_inline_values(printable_hash).join(", ")} #{colorize("}", :array)}"
        end
      end

      private def multiline_hash : String
        data = printable_hash

        if should_be_limited?
          data = limited(data, left_width(printable_keys), true)
          separator_index = get_limit_size // 2
          data[separator_index] = "#{indent(inspector.indent_size)}#{data[separator_index]}"
        end

        "#{colorize("{", :array)}\n#{data.join(",\n")}\n#{indent}#{colorize("}", :array)}"
      end

      private def printable_hash : Array(String)
        keys = printable_keys
        width = left_width(keys)

        keys.map do |key_string, value, symbol_key|
          indented do
            if symbol_key
              "#{align(key_string, width)} #{inspector.awesome(value)}"
            else
              "#{align(key_string, width)}#{colorize(" => ", :hash)}#{inspector.awesome(value)}"
            end
          end
        end
      end

      private def printable_keys
        entries = hash.map do |key, value|
          {format_key(key), value, key.is_a?(Symbol)}
        end

        if inspector.order.sorted?
          entries.sort_by { |entry| entry[0] }
        else
          entries
        end
      end

      private def left_width(keys) : Int32
        width = keys.max_of { |entry| colorless_size(entry[0]) }
        width + inspector.indent_size.abs
      end

      private def format_key(key) : String
        case key
        when Symbol
          colorize("#{key}:", :symbol)
        when String
          colorize(key.inspect, :string)
        else
          key_inspector.awesome(key)
        end
      end

      private def key_inspector : Inspector
        @key_inspector ||= Inspector.new(
          indent_size: inspector.indent_size,
          multiline: false,
          index: inspector.index,
          limit: inspector.limit,
          colors_enabled: inspector.colors_enabled,
          order: inspector.order
        )
      end
    end
  end
end
