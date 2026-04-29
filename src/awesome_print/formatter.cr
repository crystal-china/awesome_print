module AwesomePrint
  class Formatter
    getter inspector : Inspector

    def initialize(@inspector : Inspector = Inspector.new)
    end

    def format(object) : String
      case object
      when Nil, Bool, Number, Char, Symbol, String
        object.pretty_inspect(indent: inspector.indent_size).to_s
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
