module AwesomePrint
  module Formatters
    class ArrayFormatter(T) < BaseFormatter
      getter array : Array(T)

      def initialize(@array : Array(T), inspector : Inspector)
        super(inspector)
      end

      def format : String
        array.pretty_inspect(indent: inspector.indent_size).to_s
      end
    end
  end
end
