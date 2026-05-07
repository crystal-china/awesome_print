module AwesomePrint
  module Formatters
    class TupleFormatter(T) < BaseFormatter
      getter tuple : T

      def initialize(@tuple : T, inspector : Inspector)
        super(inspector)
      end

      def format : String
        values = tuple.to_a
        return colorize("{}", :array) if values.empty?

        if inspector.multiline
          multiline_indexed_collection(values, colorize("{", :array), colorize("}", :array))
        else
          "#{colorize("{", :array)} #{inline_values(values).join(", ")} #{colorize("}", :array)}"
        end
      end

      private def inline_values(values : Array) : Array(String)
        inline_collection_values(values)
      end
    end
  end
end
