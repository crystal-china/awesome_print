module AwesomePrint
  module Formatters
    class RegexFormatter < BaseFormatter
      getter regex : Regex

      def initialize(@regex : Regex, inspector : Inspector)
        super(inspector)
      end

      def format : String
        source = regex.source
        options = option_suffix

        String.build do |io|
          io << colorize("/", :array)
          io << colorize(source, :string)
          io << colorize("/", :array)
          io << colorize(options, :symbol) unless options.empty?
        end
      end

      private def option_suffix : String
        regex.inspect.byte_slice(regex.source.bytesize + 2..) || ""
      end
    end
  end
end
