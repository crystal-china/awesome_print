module AwesomePrint
  module Formatters
    class HashFormatter(K, V) < BaseFormatter
      getter hash : Hash(K, V)

      def initialize(@hash : Hash(K, V), inspector : Inspector)
        super(inspector)
      end

      def format : String
        hash.pretty_inspect(indent: inspector.indent_size).to_s
      end
    end
  end
end
