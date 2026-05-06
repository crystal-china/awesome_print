module AwesomePrint
  module Formatters
    class DirFormatter < BaseFormatter
      getter dir : Dir

      def initialize(@dir : Dir, inspector : Inspector)
        super(inspector)
      end

      def format : String
        colorize(dir.inspect, :dir)
      end
    end
  end
end
