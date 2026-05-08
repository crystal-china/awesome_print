module AwesomePrint
  class_property output : IO = STDOUT

  def self.format(value, inspector : Inspector = Inspector.new(indent_size: 4, colors_enabled: false)) : String
    pretty(value, inspector)
  end

  def self.format(value, **options) : String
    format(value, Inspector.new(**{colors_enabled: false}.merge(options)))
  end

  def self.print(*, expression : String, value, file : String, line : Int32, inspector : Inspector = Inspector.new(indent_size: 4))
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
      io << Colors.grayish("#{relative_file(file)}:#{line}", inspector.colorize?)
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
end
