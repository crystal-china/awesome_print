module AwesomePrint
  module Formatters
    class PathFormatter < BaseFormatter
      getter path : Path

      def initialize(@path : Path, inspector : Inspector)
        super(inspector)
      end

      def format : String
        "#{colorize("Path[", :class)}#{inspector.awesome(path.to_s)}#{colorize("]", :array)}"
      end
    end
  end
end
