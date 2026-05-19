module AwesomePrint
  class_property output : IO = STDOUT

  def self.format(value, inspector : Inspector = Inspector.from_defaults(default_colors_enabled: false)) : String
    pretty(value, inspector)
  end

  def self.format(value, **options) : String
    format(value, Inspector.from_defaults(**options, default_colors_enabled: false))
  end

  def self.print(*, expression : String, value, file : String, line : Int32, inspector : Inspector = Inspector.from_defaults)
    rendered_type = typeof(value).to_s

    output << header(file, line, expression, rendered_type, inspector)
    output << '\n'
    pretty_into(output, value, inspector)
    output << '\n'
    output.flush
  end

  private def self.pretty(value, inspector : Inspector) : String
    inspector.awesome(value)
  end

  private def self.pretty_into(io : IO, value, inspector : Inspector) : Nil
    inspector.write_awesome(io, value)
  end

  private def self.header(file : String, line : Int32, expression : String, rendered_type : String, inspector : Inspector) : String
    String.build do |io|
      io << Colors.blue("#{display_file(file, inspector)}:#{line}", inspector.colorize?)
      io << "  "
      io << Colors.white(expression, inspector.colorize?)
      io << "  "
      io << Colors.hash("(", inspector.colorize?)
      io << Colors.class(rendered_type, inspector.colorize?)
      io << Colors.hash(")", inspector.colorize?)
    end
  end

  private def self.relative_file(file : String) : String
    root = "#{Dir.current}/"
    file.starts_with?(root) ? file.lchop(root) : file
  end

  private def self.display_file(file : String, inspector : Inspector) : String
    path = relative_file(file)
    max = inspector.max_path_length
    return path unless max
    return path if max <= 0 || path.size <= max

    "…#{path[-(max - 1)..]}"
  end
end
