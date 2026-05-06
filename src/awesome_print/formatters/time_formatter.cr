module AwesomePrint
  module Formatters
    class TimeFormatter < BaseFormatter
      getter time : Time

      def initialize(@time : Time, inspector : Inspector)
        super(inspector)
      end

      def format : String
        value = time.inspect

        if match = value.match(/^(\d{4}-\d{2}-\d{2})( )(\d{2}:\d{2}:\d{2}(?:\.\d+)?)(.*)$/)
          String.build do |io|
            io << colorize(match[1], :time)
            io << colorize(match[2], :hash)
            io << colorize(match[3], :time)
            io << colorize(match[4], :hash)
          end
        else
          colorize(value, :time)
        end
      end
    end
  end
end
