module AwesomePrint
  module Formatters
    class FileFormatter < BaseFormatter
      getter file : File

      def initialize(@file : File, inspector : Inspector)
        super(inspector)
      end

      def format : String
        colorize(file.inspect, :file)
      end
    end
  end
end
