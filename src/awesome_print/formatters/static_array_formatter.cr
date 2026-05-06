module AwesomePrint
  module Formatters
    class StaticArrayFormatter(T, N) < ArrayFormatter(T)
      getter static_array : StaticArray(T, N)

      def initialize(@static_array : StaticArray(T, N), inspector : Inspector)
        super(@static_array.to_a, inspector)
      end

      protected def empty_value : String
        opening_token, closing_token = colored_label_wrapper("StaticArray")
        "#{opening_token}#{closing_token}"
      end

      protected def opening_token : String
        colored_label_wrapper("StaticArray")[0]
      end

      protected def singleline_collection : String
        "#{opening_token}#{inline_values.join(", ")}#{closing_token}"
      end
    end
  end
end
