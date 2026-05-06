module AwesomePrint
  module Formatters
    class SliceFormatter(T) < BaseFormatter
      getter slice : Slice(T)

      def initialize(@slice : Slice(T), inspector : Inspector)
        super(inspector)
      end

      def format : String
        return empty_value if slice.empty?

        if inspector.multiline
          multiline_indexed_collection(slice, opening_token, closing_token)
        else
          "#{opening_token}#{formatted_values.join(", ")}#{closing_token}"
        end
      end

      protected def label : String
        "Slice"
      end

      protected def formatted_values : Array(String)
        limited_inline_values(slice.map { |item| inspector.awesome(item) }.to_a)
      end

      protected def empty_value : String
        opening_token, closing_token = colored_label_wrapper(label)
        "#{opening_token}#{closing_token}"
      end

      protected def opening_token : String
        colored_label_wrapper(label)[0]
      end

      protected def closing_token : String
        colored_label_wrapper(label)[1]
      end
    end
  end
end
