module AwesomePrint
  module Formatters
    class PathFormatter < BaseFormatter
      getter path : Path

      def initialize(@path : Path, inspector : Inspector)
        super(inspector)
      end

      def format : String
        String.build do |io|
          io << colorize("Path", :class)
          io << colorize("[", :array)
          io << inspector.awesome(path.to_s)
          io << colorize("]", :array)
        end
      end
    end
  end
end
