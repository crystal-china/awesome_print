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

      def write(io : IO) : Nil
        if slice.empty?
          io << empty_value
          return
        end

        if inspector.multiline
          write_multiline_indexed_collection(io, slice, opening_token, closing_token)
        else
          write_inline_collection(io, slice, opening_token, closing_token, spacing: false)
        end
      end

      protected def label : String
        "Slice"
      end

      protected def formatted_values : Array(String)
        inline_collection_values(slice)
      end

      protected def empty_value : String
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
