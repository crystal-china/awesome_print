module AwesomePrint
  class Formatter
    getter inspector : Inspector

    def initialize(@inspector : Inspector = Inspector.new)
    end

    def format(object) : String
      case object
      when Array
        Formatters::ArrayFormatter.new(object, inspector).format
      when Hash
        Formatters::HashFormatter.new(object, inspector).format
      when NamedTuple
        Formatters::NamedTupleFormatter.new(object, inspector).format
      else
        Formatters::ObjectFormatter.new(object, inspector).format
      end
    end
  end
end
