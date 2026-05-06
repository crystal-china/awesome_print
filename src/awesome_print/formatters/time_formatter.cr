module AwesomePrint
  module Formatters
    class TimeFormatter < BaseFormatter
      getter time : Time

      def initialize(@time : Time, inspector : Inspector)
        super(inspector)
      end

      def format : String
        colorize(time.inspect, :time)
      end
    end
  end
end
