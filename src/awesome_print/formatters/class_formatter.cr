module AwesomePrint
  module Formatters
    class ClassFormatter(T) < BaseFormatter
      getter klass : T

      def initialize(@klass : T, inspector : Inspector)
        super(inspector)
      end

      def format : String
        colorize(klass.inspect, :class)
      end
    end
  end
end
