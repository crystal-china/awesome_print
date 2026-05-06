module AwesomePrint
  module Formatters
    class EnumFormatter(T) < BaseFormatter
      getter enum_value : T

      def initialize(@enum_value : T, inspector : Inspector)
        super(inspector)
      end

      def format : String
        colorize({{ T.name.stringify }}, :class) + colorize("::", :hash) + colorize(enum_value.to_s, :symbol)
      end
    end
  end
end
