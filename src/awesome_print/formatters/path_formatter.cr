module AwesomePrint
  module Formatters
    class PathFormatter < BaseFormatter
      getter path : Path

      def initialize(@path : Path, inspector : Inspector)
        super(inspector)
      end

      def format : String
        opening_token, closing_token = colored_label_wrapper("Path")
        "#{opening_token}#{inspector.awesome(path.to_s)}#{closing_token}"
      end
    end
  end
end
