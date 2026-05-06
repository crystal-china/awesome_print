module AwesomePrint
  module Formatters
    class ArrayFormatter(T) < BaseFormatter
      getter array : Array(T)

      def initialize(@array : Array(T), inspector : Inspector)
        super(inspector)
      end

      def format : String
        return empty_value if array.empty?

        if inspector.multiline
          multiline_collection
        else
          singleline_collection
        end
      end

      private def multiline_collection : String
        data = generate_printable_array
        if should_be_limited?
          data = limited(data, width(array))
          separator_index = get_limit_size // 2
          data[separator_index] = "#{indent(inspector.indent_size)}#{data[separator_index]}"
        end
        "#{opening_token}\n#{data.join(",\n")}\n#{indent}#{closing_token}"
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

      protected def empty_value : String
        colorize("[]", :array)
      end

      protected def opening_token : String
        colorize("[", :array)
      end

      protected def closing_token : String
        colorize("]", :array)
      end

      protected def singleline_collection : String
        "#{opening_token} #{array.map { |item| inspector.awesome(item) }.join(", ")} #{closing_token}"
      end
    end
  end
end
