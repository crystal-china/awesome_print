module AwesomePrint
  class Inspector
    enum Order
      Natural
      Sorted
    end

    enum HashFormat
      Symbol
      Rocket
      Json
    end

    getter indent_size : Int32
    getter current_indentation : Int32
    getter multiline : Bool
    getter index : Bool
    getter limit : Int32?
    getter raw : Bool
    getter colors_enabled : Bool
    getter show_backtrace : Bool
    getter backtrace_limit : Int32
    getter object_id : Bool
    getter order : Order
    getter hash_format : HashFormat

    def initialize(
      @indent_size : Int32 = 4,
      @multiline : Bool = true,
      @index : Bool = true,
      @limit : Int32? = nil,
      @raw : Bool = false,
      @colors_enabled : Bool = true,
      @show_backtrace : Bool = true,
      @backtrace_limit : Int32 = 8,
      @object_id : Bool = true,
      @order : Order = :natural,
      @hash_format : HashFormat = :symbol
    )
      @current_indentation = 0
      @seen_object_ids = [] of UInt64
      @formatter = nil
    end

    def increase_indentation(&)
      @current_indentation += @indent_size.abs
      yield
    ensure
      @current_indentation -= @indent_size.abs
    end

    def colorize? : Bool
      @colors_enabled
    end

    def awesome(object) : String
      case object
      when Reference
        if recursive?(object)
          nested(object)
        else
          begin
            @seen_object_ids << object.object_id
            formatter.format(object)
          ensure
            @seen_object_ids.pop
          end
        end
      else
        formatter.format(object)
      end
    end

    def write_awesome(io : IO, object) : Nil
      case object
      when Reference
        if recursive?(object)
          io << nested(object)
        else
          begin
            @seen_object_ids << object.object_id
            formatter.write(object, io)
          ensure
            @seen_object_ids.pop
          end
        end
      else
        formatter.write(object, io)
      end
    end

    private def recursive?(object : Reference) : Bool
      @seen_object_ids.includes?(object.object_id)
    end

    def recursive_reference?(object) : Bool
      object.is_a?(Reference) && recursive?(object)
    end

    private def formatter : Formatter
      @formatter ||= Formatter.new(self)
    end

    private def nested(object : Reference) : String
      case object
      when Array
        Colors.apply(:array, "[...]", colorize?)
      when Hash
        Colors.apply(:hash, "{...}", colorize?)
      else
        Colors.apply(:class, "...#{object.class}...", colorize?)
      end
    end
  end
end
