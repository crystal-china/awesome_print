module AwesomePrint
  module Formatters
    class SliceFormatter(T) < BaseFormatter
      getter slice : Slice(T)

      def initialize(@slice : Slice(T), inspector : Inspector)
        super(inspector)
      end

      def format : String
        return empty_value if slice.empty?

        if inspector.multiline
          multiline_slice
        else
          "#{opening_token}#{formatted_values.join(", ")}#{closing_token}"
        end
      end

      protected def label : String
        "Slice"
      end

      protected def formatted_values : Array(String)
        limited_inline_values(slice.map { |item| inspector.awesome(item) }.to_a)
      end

      protected def empty_value : String
        "#{colorize(label, :class)}#{colorize("[]", :array)}"
      end

      protected def opening_token : String
        "#{colorize(label, :class)}#{colorize("[", :array)}"
      end

      protected def closing_token : String
        colorize("]", :array)
      end

      private def multiline_slice : String
        data = generate_printable_slice
        if should_be_limited?
          data = limited(data, width(slice))
          separator_index = get_limit_size // 2
          data[separator_index] = "#{indent(inspector.indent_size)}#{data[separator_index]}"
        end

        "#{opening_token}\n#{data.join(",\n")}\n#{indent}#{closing_token}"
      end

      private def generate_printable_slice : Array(String)
        slice.map_with_index do |item, index|
          indented do
            "#{indent}#{colorize("[#{index.to_s.rjust(width(slice))}] ", :array)}#{inspector.awesome(item)}"
          end
        end.to_a
      end

      private def width(items) : Int32
        (items.size - 1).to_s.size
      end
    end
  end
end
