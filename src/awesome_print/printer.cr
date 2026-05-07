module AwesomePrint
  class_property output : IO = STDOUT

  def self.format(value, inspector : Inspector = Inspector.new(indent_size: 4)) : String
    pretty(value, inspector)
  end

  def self.format(value, **options) : String
    format(value, Inspector.new(**options))
  end

  def self.print(*, expression : String, value, file : String, line : Int32, inspector : Inspector = Inspector.new(indent_size: 2))
    rendered_value = pretty(value, inspector)
    rendered_type = typeof(value).to_s

    output << file << ":" << line << " -- " << expression << " ="
    output << '\n'
    output << rendered_value
    output << '\n' unless rendered_value.ends_with?('\n')
    output << "(" << rendered_type << ")" << '\n'
    output.flush
  end

  private def self.pretty(value, inspector : Inspector) : String
    inspector.awesome(value)
  end
end
