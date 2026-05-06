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
          "#{colorize("(", :array)} #{values.map { |item| inspector.awesome(item) }.join(", ")} #{colorize(")", :array)}"
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

      private def limited_values(data : Array(String)) : Array(String)
        limit = get_limit_size
        return data if data.size <= limit

        head = limit // 2
        tail = head - ((limit - 1) % 2)
        data[0, head] + ["#{indent(inspector.indent_size)}.."] + data[-tail, tail]
      end
    end
  end
end
