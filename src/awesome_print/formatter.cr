module AwesomePrint
  class Formatter
    getter inspector : Inspector

    def initialize(@inspector : Inspector = Inspector.new)
    end

    def format(object) : String
      case object
      when Nil
        Colors.nilclass("nil", inspector.colorize?)
      when Bool
        Colors.apply(object ? :trueclass : :falseclass, object.to_s, inspector.colorize?)
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
      when Bytes
        Formatters::BytesFormatter.new(object, inspector).format
      when Slice
        Formatters::SliceFormatter.new(object, inspector).format
      when Class
        Formatters::ClassFormatter.new(object, inspector).format
      when Enum
        Formatters::EnumFormatter.new(object, inspector).format
      when Exception
        Formatters::ExceptionFormatter.new(object, inspector).format
      when Dir
        Formatters::DirFormatter.new(object, inspector).format
      when File
        Formatters::FileFormatter.new(object, inspector).format
      when Path
        Formatters::PathFormatter.new(object, inspector).format
      when Regex
        Formatters::RegexFormatter.new(object, inspector).format
      when Range
        Formatters::RangeFormatter.new(object, inspector).format
      when Time
        Formatters::TimeFormatter.new(object, inspector).format
      when Set
        Formatters::SetFormatter.new(object, inspector).format
      when StaticArray
        Formatters::StaticArrayFormatter.new(object, inspector).format
      when Tuple
        Formatters::TupleFormatter.new(object, inspector).format
      when Hash
        Formatters::HashFormatter.new(object, inspector).format
      when NamedTuple
        Formatters::NamedTupleFormatter.new(object, inspector).format
      when Struct
        Formatters::StructFormatter.new(object, inspector).format
      else
        if !inspector.raw && (mapping = convert_to_mapping(object))
          format(mapping)
        else
          Formatters::ObjectFormatter.new(object, inspector).format
        end
      end
    end

    private def convert_to_mapping(object)
      return unless object.responds_to?(:to_h)

      mapping = object.to_h
      case mapping
      when Hash, NamedTuple
        mapping
      else
        nil
      end
    end
  end
end
