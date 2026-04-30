module AwesomePrint
  class Formatter
    getter inspector : Inspector

    def initialize(@inspector : Inspector = Inspector.new)
    end

    def format(object) : String
      case object
      when Nil
        Colors.apply(:keyword, "nil", inspector.colorize?)
      when Bool
        Colors.apply(:keyword, object.to_s, inspector.colorize?)
      when Number
        Colors.apply(:number, object.to_s, inspector.colorize?)
      when Char
        Colors.apply(:string, object.inspect, inspector.colorize?)
      when Symbol
        Colors.apply(:symbol, object.inspect, inspector.colorize?)
      when String
        Colors.apply(:string, object.inspect, inspector.colorize?)
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
