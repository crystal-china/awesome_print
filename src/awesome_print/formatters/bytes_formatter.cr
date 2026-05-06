module AwesomePrint
  module Formatters
    class BytesFormatter < BaseFormatter
      getter bytes : Bytes

      def initialize(@bytes : Bytes, inspector : Inspector)
        super(inspector)
      end

      def format : String
        values = byte_values
        "#{colorize("Bytes[", :class)}#{values.join(", ")}#{colorize("]", :array)}"
      end

      private def byte_values : Array(String)
        values = bytes.map { |byte| colorize(byte.to_s, :number) }.to_a
        return values unless should_be_limited? && values.size > get_limit_size

        head = get_limit_size // 2
        tail = head - ((get_limit_size - 1) % 2)
        values[0, head] + [".."] + values[-tail, tail]
      end
    end
  end
end
