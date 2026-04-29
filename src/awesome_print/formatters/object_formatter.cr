module AwesomePrint
  module Formatters
    class ObjectFormatter(T) < BaseFormatter
      getter object : T

      def initialize(@object : T, inspector : Inspector)
        super(inspector)
      end

      def format : String
        object.pretty_inspect(indent: inspector.indent_size).to_s
      end
    end
  end
end
