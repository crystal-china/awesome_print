module AwesomePrint
  module Formatters
    class RangeFormatter(B, E) < BaseFormatter
      getter range : Range(B, E)

      def initialize(@range : Range(B, E), inspector : Inspector)
        super(inspector)
      end

      def format : String
        "#{inspector.awesome(range.begin)}#{colorize(operator, :hash)}#{inspector.awesome(range.end)}"
      end

      private def operator : String
        range.excludes_end? ? "..." : ".."
      end
    end
  end
end
