module AwesomePrint
  module Formatters
    class RegexFormatter < BaseFormatter
      getter regex : Regex

      def initialize(@regex : Regex, inspector : Inspector)
        super(inspector)
      end

      def format : String
        colorize(regex.inspect, :string)
      end
    end
  end
end
