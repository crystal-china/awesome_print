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

        head, tail = limited_partition_counts(limit)
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

        head, tail = limited_partition_counts(limit)
        data[0, head] + [".."] + data[-tail, tail]
      end

      def multiline_indexed_collection(items, opening_token : String, closing_token : String) : String
        data = indexed_collection_lines(items)

        "#{opening_token}\n#{data.join(",\n")}\n#{indent}#{closing_token}"
      end

      def write_multiline_indexed_collection(io : IO, items, opening_token : String, closing_token : String) : Nil
        io << opening_token << '\n'

        width = index_width(items.size)
        if partition = limited_partition(items.size)
          head, tail = partition

          head.times do |index|
            io << formatted_indexed_item(items[index], index, width)
            io << ",\n"
          end

          io << indented do
            "#{indent}[#{head.to_s.rjust(width)}] .. [#{items.size - tail - 1}]"
          end

          if tail.positive?
            io << ",\n"
          end

          tail.times do |offset|
            index = items.size - tail + offset
            io << formatted_indexed_item(items[index], index, width)
            io << ",\n" unless offset == tail - 1
          end
        else
          items.each_with_index do |item, index|
            io << formatted_indexed_item(item, index, width)
            io << ",\n" unless index == items.size - 1
          end
        end

        io << '\n' << indent << closing_token
      end

      def indexed_collection_lines(items) : Array(String)
        width = index_width(items.size)
        if partition = limited_partition(items.size)
          head, tail = partition
          data = Array(String).new(head + tail + 1)

          head.times do |index|
            data << formatted_indexed_item(items[index], index, width)
          end

          data << indented do
            "#{indent}[#{head.to_s.rjust(width)}] .. [#{items.size - tail - 1}]"
          end

          tail.times do |offset|
            index = items.size - tail + offset
            data << formatted_indexed_item(items[index], index, width)
          end

          data
        else
          items.map_with_index do |item, index|
            formatted_indexed_item(item, index, width)
          end.to_a
        end
      end

      def inline_collection_values(items) : Array(String)
        if partition = limited_partition(items.size)
          head, tail = partition
          data = Array(String).new(head + tail + 1)

          head.times do |index|
            data << inspector.awesome(items[index])
          end

          data << ".."

          tail.times do |offset|
            data << inspector.awesome(items[items.size - tail + offset])
          end

          data
        else
          items.map { |item| inspector.awesome(item) }.to_a
        end
      end

      def write_inline_collection(io : IO, items, opening_token : String, closing_token : String, spacing : Bool = true) : Nil
        io << opening_token
        io << ' ' if spacing

        values = inline_collection_values(items)
        values.each_with_index do |value, index|
          io << value
          io << ", " unless index == values.size - 1
        end

        io << ' ' if spacing
        io << closing_token
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

      private def formatted_indexed_item(item, index : Int32, width : Int32) : String
        indented do
          indexed_collection_prefix(index, width) + inspector.awesome(item)
        end
      end

      private def limited_partition(size : Int32) : {Int32, Int32}?
        return unless should_be_limited?
        return unless size > get_limit_size

        limited_partition_counts(get_limit_size)
      end

      private def limited_partition_counts(limit : Int32) : {Int32, Int32}
        head = limit // 2
        tail = head - ((limit - 1) % 2)
        {head, tail}
      end

      def colored_label_wrapper(label : String, opening : String = "[", closing : String = "]") : {String, String}
        {
          "#{colorize(label, :class)}#{colorize(opening, :array)}",
          colorize(closing, :array),
        }
      end

      def singleline_braced_collection(data : Array(String)) : String
        "#{colorize("{", :array)} #{limited_inline_values(data).join(", ")} #{colorize("}", :array)}"
      end

      def multiline_braced_mapping(data : Array(String), width : Int32) : String
        if should_be_limited?
          data = limited(data, width, true)
          separator_index = get_limit_size // 2
          data[separator_index] = "#{indent(inspector.indent_size)}#{data[separator_index]}"
        end

        "#{colorize("{", :array)}\n#{data.join(",\n")}\n#{indent}#{colorize("}", :array)}"
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
