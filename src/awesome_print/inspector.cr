module AwesomePrint
  class Inspector
    enum Order
      Natural
      Sorted
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
    getter order : Order

    def initialize(
      @indent_size : Int32 = 4,
      @multiline : Bool = true,
      @index : Bool = true,
      @limit : Int32? = nil,
      @raw : Bool = false,
      @colors_enabled : Bool = true,
      @show_backtrace : Bool = true,
      @backtrace_limit : Int32 = 8,
      @order : Order = :natural
    )
      @current_indentation = 0
      @seen_object_ids = [] of UInt64
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
            Formatter.new(self).format(object)
          ensure
            @seen_object_ids.pop
          end
        end
      else
        Formatter.new(self).format(object)
      end
    end

    private def recursive?(object : Reference) : Bool
      @seen_object_ids.includes?(object.object_id)
    end

    def recursive_reference?(object) : Bool
      object.is_a?(Reference) && recursive?(object)
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
