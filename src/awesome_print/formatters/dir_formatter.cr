module AwesomePrint
  module Formatters
    class DirFormatter < BaseFormatter
      getter dir : Dir

      def initialize(@dir : Dir, inspector : Inspector)
        super(inspector)
      end

      def format : String
        String.build do |io|
          io << colorize("#<", :hash)
          io << colorize("Dir", :class)
          io << colorize(":", :hash)
          io << colorize(dir.path, :string)
          io << colorize(">", :hash)
        end
      end
    end
  end
end
