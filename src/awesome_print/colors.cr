require "colorize"

module AwesomePrint
  module Colors
    extend self

    COLORS = Hash(Symbol, Colorize::Color){
      :array     => Colorize::ColorANSI::White,
      :hash      => Colorize::ColorANSI::LightGray,
      :struct    => Colorize::ColorANSI::LightGray,
      :class     => Colorize::ColorANSI::Yellow,
      :variable  => Colorize::ColorANSI::LightCyan,
      :string    => Colorize::ColorANSI::LightYellow,
      :symbol    => Colorize::ColorANSI::LightCyan,
      :number    => Colorize::ColorANSI::Blue,
      :time      => Colorize::ColorANSI::LightGreen,
      :nilclass  => Colorize::ColorANSI::Red,
      :trueclass => Colorize::ColorANSI::Green,
      :falseclass => Colorize::ColorANSI::Red,
      :keyword   => Colorize::ColorANSI::Red,
      :gray      => Colorize::ColorANSI::LightGray,
      :red       => Colorize::ColorANSI::Red,
      :green     => Colorize::ColorANSI::Green,
      :yellow    => Colorize::ColorANSI::Yellow,
      :blue      => Colorize::ColorANSI::Blue,
      :purple    => Colorize::ColorANSI::Magenta,
      :cyan      => Colorize::ColorANSI::Cyan,
      :white     => Colorize::ColorANSI::White,
      :grayish   => Colorize::ColorANSI::DarkGray,
      :redish    => Colorize::ColorANSI::LightRed,
      :greenish  => Colorize::ColorANSI::LightGreen,
      :yellowish => Colorize::ColorANSI::LightYellow,
      :blueish   => Colorize::ColorANSI::LightBlue,
      :purpleish => Colorize::ColorANSI::LightMagenta,
      :cyanish   => Colorize::ColorANSI::LightCyan,
      :whiteish  => Colorize::ColorANSI::LightGray,
      :pale      => Colorize::ColorANSI::LightGray,
    }

    def apply(name : Symbol, value : String, enabled : Bool = true) : String
      return value unless enabled

      color = COLORS[name]?
      return value unless color

      colored = value.colorize(color)
      colored = colored.mode(:bold) if name == :array || name == :number
      colored.toggle(enabled).to_s
    end

    {% for name in [:array, :hash, :struct, :class, :variable, :string, :symbol, :number, :time,
                    :nilclass, :trueclass, :falseclass, :keyword,
                    :gray, :red, :green, :yellow, :blue, :purple, :cyan, :white,
                    :grayish, :redish, :greenish, :yellowish, :blueish, :purpleish,
                    :cyanish, :whiteish, :pale] %}
      def {{ name.id }}(value : String, enabled : Bool = true) : String
        apply(:{{ name.id }}, value, enabled)
      end
    {% end %}
  end
end
