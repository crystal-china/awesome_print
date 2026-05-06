module AwesomePrint
  module Formatters
    class SliceFormatter(T) < BaseFormatter
      getter slice : Slice(T)

      def initialize(@slice : Slice(T), inspector : Inspector)
        super(inspector)
      end

      def format : String
        "#{colorize("#{label}[", :class)}#{formatted_values.join(", ")}#{colorize("]", :array)}"
      end

      protected def label : String
        "Slice"
      end

      protected def formatted_values : Array(String)
        values = slice.map { |item| inspector.awesome(item) }.to_a
        return values unless should_be_limited? && values.size > get_limit_size

        head = get_limit_size // 2
        tail = head - ((get_limit_size - 1) % 2)
        values[0, head] + [".."] + values[-tail, tail]
      end
    end
  end
end
