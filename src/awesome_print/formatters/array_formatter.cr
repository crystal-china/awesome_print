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
          multiline_indexed_collection(array, opening_token, closing_token)
        else
          singleline_collection
        end
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
        "#{opening_token} #{inline_values.join(", ")} #{closing_token}"
      end

      protected def inline_values : Array(String)
        inline_collection_values(array)
      end
    end
  end
end
