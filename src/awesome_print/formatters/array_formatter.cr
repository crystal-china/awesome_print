module AwesomePrint
  module Formatters
    class ArrayFormatter(T) < BaseFormatter
      getter array : Array(T)

      def initialize(@array : Array(T), inspector : Inspector)
        super(inspector)
      end

      def format : String
        return colorize("[]", :array) if array.empty?

        if inspector.multiline
          multiline_array
        else
          "#{colorize("[", :array)} #{array.map { |item| inspector.awesome(item) }.join(", ")} #{colorize("]", :array)}"
        end
      end

      private def multiline_array : String
        data = generate_printable_array
        if should_be_limited?
          data = limited(data, width(array))
          separator_index = get_limit_size // 2
          data[separator_index] = "#{indent(inspector.indent_size)}#{data[separator_index]}"
        end
        "#{colorize("[", :array)}\n#{data.join(",\n")}\n#{indent}#{colorize("]", :array)}"
      end

      private def generate_printable_array : Array(String)
        array.map_with_index do |item, index|
          indented do
            array_prefix(index, width(array)) + inspector.awesome(item)
          end
        end
      end

      private def array_prefix(index : Int32, width : Int32) : String
        if inspector.index
          indent + colorize("[#{index.to_s.rjust(width)}] ", :array)
        else
          indent
        end
      end

      private def width(items : Array) : Int32
        (items.size - 1).to_s.size
      end
    end
  end
end
