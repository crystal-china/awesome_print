module AwesomePrint
  module Formatters
    class FileFormatter < BaseFormatter
      getter file : File

      def initialize(@file : File, inspector : Inspector)
        super(inspector)
      end

      def format : String
        String.build do |io|
          io << colorize("#<", :hash)
          io << colorize("File", :class)
          io << colorize(":", :hash)
          io << colorize(file.path, :string)
          io << colorize(">", :hash)
        end
      end
    end
  end
end
