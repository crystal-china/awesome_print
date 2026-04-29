module AwesomePrint
  class_property output : IO = STDOUT

  def self.print(*, expression : String, value, file : String, line : Int32)
    rendered_value = pretty(value)
    rendered_type = typeof(value).to_s

    output << file << ":" << line << " -- " << expression << " ="
    output << '\n'
    output << rendered_value
    output << '\n' unless rendered_value.ends_with?('\n')
    output << "(" << rendered_type << ")" << '\n'
    output.flush
  end

  private def self.pretty(value) : String
    Inspector.new(indent_size: 2).awesome(value)
  end
end
