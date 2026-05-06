module AwesomePrint
  module Formatters
    class StaticArrayFormatter(T, N) < BaseFormatter
      getter static_array : StaticArray(T, N)

      def initialize(@static_array : StaticArray(T, N), inspector : Inspector)
        super(inspector)
      end

      def format : String
        values = static_array.to_a
        return colorize("StaticArray[]", :class) if values.empty?

        if inspector.multiline
          multiline_static_array(values)
        else
          "#{colorize("StaticArray[", :class)}#{rendered_values(values).join(", ")}#{colorize("]", :array)}"
        end
      end

      private def multiline_static_array(values : Array) : String
        data = values.map_with_index do |item, index|
          indented do
            "#{indent}#{colorize("[#{index.to_s.rjust(width(values))}] ", :array)}#{inspector.awesome(item)}"
          end
        end

        if should_be_limited?
          data = limited(data, width(values))
          separator_index = get_limit_size // 2
          data[separator_index] = "#{indent(inspector.indent_size)}#{data[separator_index]}"
        end

        "#{colorize("StaticArray[", :class)}\n#{data.join(",\n")}\n#{indent}#{colorize("]", :array)}"
      end

      private def rendered_values(values : Array) : Array(String)
        rendered = values.map { |item| inspector.awesome(item) }
        return rendered unless should_be_limited? && rendered.size > get_limit_size

        head = get_limit_size // 2
        tail = head - ((get_limit_size - 1) % 2)
        rendered[0, head] + [".."] + rendered[-tail, tail]
      end

      private def width(values : Array) : Int32
        (values.size - 1).to_s.size
      end
    end
  end
end
