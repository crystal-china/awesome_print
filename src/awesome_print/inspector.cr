module AwesomePrint
  class Inspector
    getter indent_size : Int32
    getter current_indentation : Int32
    getter multiline : Bool
    getter index : Bool
    getter limit : Int32?
    getter colors_enabled : Bool

    def initialize(
      @indent_size : Int32 = 4,
      @multiline : Bool = true,
      @index : Bool = true,
      @limit : Int32? = nil,
      @colors_enabled : Bool = true
    )
      @current_indentation = 0
    end

    def increase_indentation(&) : Nil
      @current_indentation += @indent_size.abs
      yield
    ensure
      @current_indentation -= @indent_size.abs
    end

    def colorize? : Bool
      @colors_enabled
    end
  end
end
