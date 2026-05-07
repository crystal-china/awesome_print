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

    output << file << ":" << line << " -- " << expression << " ="
    output << '\n'
    pretty_into(output, value, inspector)
    output << '\n'
    output << "(" << rendered_type << ")" << '\n'
    output.flush
  end

  private def self.pretty(value, inspector : Inspector) : String
    inspector.awesome(value)
  end

  private def self.pretty_into(io : IO, value, inspector : Inspector) : Nil
    inspector.write_awesome(io, value)
  end
end
