module AwesomePrint
  module Formatters
    abstract class BaseFormatter
      DEFAULT_LIMIT_SIZE = 7
      INDENT_CACHE = (0..100).map { |i| " " * i }

      getter inspector : Inspector

      def initialize(@inspector : Inspector)
      end

      def indentation : Int32
        inspector.current_indentation
      end

      def indented(&)
        inspector.increase_indentation { yield }
      end

      def indent(n : Int32 = indentation) : String
        if cached = INDENT_CACHE[n]?
          cached
        else
          " " * n
        end
      end

      def outdent : String
        indent((indentation - inspector.indent_size.abs).clamp(0, Int32::MAX))
      end

      def should_be_limited? : Bool
        !inspector.limit.nil?
      end

      def get_limit_size : Int32
        inspector.limit || DEFAULT_LIMIT_SIZE
      end

      def limited(data : Array(String), width : Int32, is_hash : Bool = false) : Array(String)
        limit = get_limit_size
        return data if data.size <= limit

        head = limit // 2
        tail = head - ((limit - 1) % 2)
        temp = data[0, head] + [String.new] + data[-tail, tail]

        temp[head] = if is_hash
                       "#{indent}#{data[head].strip} .. #{data[data.size - tail - 1].strip}"
                     else
                       "#{indent}[#{head.to_s.rjust(width)}] .. [#{data.size - tail - 1}]"
                     end

        temp
      end

      def limited_inline_values(data : Array(String)) : Array(String)
        limit = get_limit_size
        return data if data.size <= limit

        head = limit // 2
        tail = head - ((limit - 1) % 2)
        data[0, head] + [".."] + data[-tail, tail]
      end

      def multiline_indexed_collection(items, opening_token : String, closing_token : String) : String
        data = indexed_collection_lines(items)
        if should_be_limited?
          data = limited(data, index_width(items.size))
          separator_index = get_limit_size // 2
          data[separator_index] = "#{indent(inspector.indent_size)}#{data[separator_index]}"
        end

        "#{opening_token}\n#{data.join(",\n")}\n#{indent}#{closing_token}"
      end

      def indexed_collection_lines(items) : Array(String)
        width = index_width(items.size)
        items.map_with_index do |item, index|
          indented do
            indexed_collection_prefix(index, width) + inspector.awesome(item)
          end
        end.to_a
      end

      def indexed_collection_prefix(index : Int32, width : Int32) : String
        if inspector.index
          indent + colorize("[#{index.to_s.rjust(width)}] ", :array)
        else
          indent
        end
      end

      def index_width(size : Int32) : Int32
        (size - 1).to_s.size
      end

      def colored_label_wrapper(label : String, opening : String = "[", closing : String = "]") : {String, String}
        {
          "#{colorize(label, :class)}#{colorize(opening, :array)}",
          colorize(closing, :array),
        }
      end

      def align(value : String, width : Int32) : String
        return value unless inspector.multiline

        effective_width = width + value.size - colorless_size(value)

        if inspector.indent_size.positive?
          value.rjust(effective_width)
        elsif inspector.indent_size.zero?
          "#{indent}#{value.ljust(effective_width)}"
        else
          "#{indent(indentation + inspector.indent_size)}#{value.ljust(effective_width)}"
        end
      end

      def colorize(value : String, type : Symbol) : String
        Colors.apply(type, value, inspector.colorize?)
      end

      def colorless(value : String) : String
        value.gsub(/\e\[[\d;]+m/, "")
      end

      def colorless_size(value : String) : Int32
        colorless(value).size
      end
    end
  end
end
