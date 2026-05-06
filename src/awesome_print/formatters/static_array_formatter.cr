module AwesomePrint
  module Formatters
    class StaticArrayFormatter(T, N) < ArrayFormatter(T)
      getter static_array : StaticArray(T, N)

      def initialize(@static_array : StaticArray(T, N), inspector : Inspector)
        super(@static_array.to_a, inspector)
      end

      protected def empty_value : String
        colorize("StaticArray[]", :class)
      end

      protected def opening_token : String
        colorize("StaticArray[", :class)
      end

      protected def singleline_collection : String
        "#{opening_token}#{array.map { |item| inspector.awesome(item) }.join(", ")}#{closing_token}"
      end
    end
  end
end
