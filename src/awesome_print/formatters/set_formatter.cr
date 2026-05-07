module AwesomePrint
  module Formatters
    class SetFormatter(T) < BaseFormatter
      getter set : Set(T)

      def initialize(@set : Set(T), inspector : Inspector)
        super(inspector)
      end

      def format : String
        return colorize("()", :array) if set.empty?

        values = set.to_a
        if inspector.multiline
          multiline_set(values)
        else
          "#{colorize("(", :array)} #{inline_values(values).join(", ")} #{colorize(")", :array)}"
        end
      end

      def write(io : IO) : Nil
        if set.empty?
          io << colorize("()", :array)
          return
        end

        values = set.to_a
        if inspector.multiline
          write_multiline_set(io, values)
        else
          write_inline_collection(io, values, colorize("(", :array), colorize(")", :array))
        end
      end

      private def multiline_set(values : Array) : String
        data = values.map do |item|
          indented do
            "#{indent}#{inspector.awesome(item)}"
          end
        end

        if should_be_limited?
          data = limited_values(data)
        end

        "#{colorize("(", :array)}\n#{data.join(",\n")}\n#{indent}#{colorize(")", :array)}"
      end

      private def write_multiline_set(io : IO, values : Array) : Nil
        io << colorize("(", :array) << '\n'

        if partition = limited_partition(values.size)
          head, tail = partition

          head.times do |index|
            io << indented do
              "#{indent}#{inspector.awesome(values[index])}"
            end
            io << ",\n"
          end

          io << "#{indent(inspector.indent_size)}.."

          if tail.positive?
            io << ",\n"
          end

          tail.times do |offset|
            io << indented do
              "#{indent}#{inspector.awesome(values[values.size - tail + offset])}"
            end
            io << ",\n" unless offset == tail - 1
          end
        else
          values.each_with_index do |item, index|
            io << indented do
              "#{indent}#{inspector.awesome(item)}"
            end
            io << ",\n" unless index == values.size - 1
          end
        end

        io << '\n' << indent << colorize(")", :array)
      end
      private def limited_values(data : Array(String)) : Array(String)
        limited_inline_values(data).map_with_index do |value, index|
          value == ".." && index == get_limit_size // 2 ? "#{indent(inspector.indent_size)}.." : value
        end
      end

      private def inline_values(values : Array) : Array(String)
        limited_inline_values(values.map { |item| inspector.awesome(item) })
      end
    end
  end
end
