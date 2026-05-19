module AwesomePrint
  def self.settings : Inspector::Settings
    Inspector.settings
  end

  def self.configure(&) : Nil
    yield settings
  end

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

    class Settings
      property indent_size : Int32 = 4
      property multiline : Bool = true
      property index : Bool = true
      property limit : Int32? = nil
      property raw : Bool = false
      property colors_enabled : Bool? = nil
      property show_backtrace : Bool = true
      property backtrace_limit : Int32 = 8
      property object_id : Bool = true
      property max_path_length : Int32? = 42
      property order : Order = :natural
      property hash_format : HashFormat = :symbol
    end

    class_getter settings = Settings.new

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
    getter max_path_length : Int32?
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
      @max_path_length : Int32? = 42,
      @order : Order = :natural,
      @hash_format : HashFormat = :symbol
    )
      @current_indentation = 0
      @seen_object_ids = [] of UInt64
      @formatter = nil
    end

    def self.configure(&) : Nil
      yield settings
    end

    def self.from_defaults(*, default_colors_enabled : Bool = true, **options) : Inspector
      from_defaults(options, default_colors_enabled)
    end

    private def self.from_defaults(options : T, default_colors_enabled : Bool) : Inspector forall T
      defaults = settings
      configured_colors = defaults.colors_enabled

      new(
        indent_size: {% if T.keys.includes?(:indent_size.id) %} options[:indent_size] {% else %} defaults.indent_size {% end %},
        multiline: {% if T.keys.includes?(:multiline.id) %} options[:multiline] {% else %} defaults.multiline {% end %},
        index: {% if T.keys.includes?(:index.id) %} options[:index] {% else %} defaults.index {% end %},
        limit: {% if T.keys.includes?(:limit.id) %} options[:limit] {% else %} defaults.limit {% end %},
        raw: {% if T.keys.includes?(:raw.id) %} options[:raw] {% else %} defaults.raw {% end %},
        colors_enabled: {% if T.keys.includes?(:colors_enabled.id) %}
                          options[:colors_enabled]
                        {% else %}
                          configured_colors.nil? ? default_colors_enabled : configured_colors.not_nil!
                        {% end %},
        show_backtrace: {% if T.keys.includes?(:show_backtrace.id) %} options[:show_backtrace] {% else %} defaults.show_backtrace {% end %},
        backtrace_limit: {% if T.keys.includes?(:backtrace_limit.id) %} options[:backtrace_limit] {% else %} defaults.backtrace_limit {% end %},
        object_id: {% if T.keys.includes?(:object_id.id) %} options[:object_id] {% else %} defaults.object_id {% end %},
        max_path_length: {% if T.keys.includes?(:max_path_length.id) %} options[:max_path_length] {% else %} defaults.max_path_length {% end %},
        order: normalize_order({% if T.keys.includes?(:order.id) %} options[:order] {% else %} defaults.order {% end %}),
        hash_format: normalize_hash_format({% if T.keys.includes?(:hash_format.id) %} options[:hash_format] {% else %} defaults.hash_format {% end %})
      )
    end

    private def self.normalize_order(value : Order) : Order
      value
    end

    private def self.normalize_order(value : Symbol) : Order
      case value
      when :natural then Order::Natural
      when :sorted  then Order::Sorted
      else
        raise ArgumentError.new("Invalid order: #{value.inspect}")
      end
    end

    private def self.normalize_hash_format(value : HashFormat) : HashFormat
      value
    end

    private def self.normalize_hash_format(value : Symbol) : HashFormat
      case value
      when :symbol then HashFormat::Symbol
      when :rocket then HashFormat::Rocket
      when :json   then HashFormat::Json
      else
        raise ArgumentError.new("Invalid hash_format: #{value.inspect}")
      end
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
