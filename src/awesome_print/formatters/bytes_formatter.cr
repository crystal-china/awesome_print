module AwesomePrint
  module Formatters
    class BytesFormatter < SliceFormatter(UInt8)
      def initialize(bytes : Bytes, inspector : Inspector)
        super(bytes, inspector)
      end

      protected def label : String
        "Bytes"
      end
    end
  end
end
