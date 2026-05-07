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
          multiline_braced_mapping(printable_hash, left_width(printable_keys))
        else
          singleline_braced_collection(printable_hash)
        end
      end

      private def printable_hash : Array(String)
        keys = printable_keys
        width = left_width(keys)

        keys.map do |key_string, value, key_type|
          indented do
            formatted_entry(key_string, value, key_type, width)
          end
        end
      end

      private def printable_keys
        entries = hash.map do |key, value|
          {format_key(key), value, key_type(key)}
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
          case inspector.hash_format
          when .json?
            colorize(key.to_s.inspect, :string)
          when .rocket?
            colorize(key.inspect, :symbol)
          else
            colorize("#{key}:", :symbol)
          end
        when String
          colorize(key.inspect, :string)
        else
          key_inspector.awesome(key)
        end
      end

      private def formatted_entry(key_string : String, value, key_type : Symbol, width : Int32) : String
        case inspector.hash_format
        when .json?
          if key_type.in?({:symbol, :string})
            "#{align(key_string, width)}#{colorize(": ", :hash)}#{inspector.awesome(value)}"
          else
            "#{align(key_string, width)}#{colorize(" => ", :hash)}#{inspector.awesome(value)}"
          end
        when .rocket?
          "#{align(key_string, width)}#{colorize(" => ", :hash)}#{inspector.awesome(value)}"
        else
          if key_type == :symbol
            "#{align(key_string, width)} #{inspector.awesome(value)}"
          else
            "#{align(key_string, width)}#{colorize(" => ", :hash)}#{inspector.awesome(value)}"
          end
        end
      end

      private def key_type(key) : Symbol
        case key
        when Symbol then :symbol
        when String then :string
        else             :other
        end
      end

      private def key_inspector : Inspector
        @key_inspector ||= Inspector.new(
          indent_size: inspector.indent_size,
          multiline: false,
          index: inspector.index,
          limit: inspector.limit,
          raw: inspector.raw,
          colors_enabled: inspector.colors_enabled,
          show_backtrace: inspector.show_backtrace,
          backtrace_limit: inspector.backtrace_limit,
          order: inspector.order,
          hash_format: inspector.hash_format
        )
      end
    end
  end
end
