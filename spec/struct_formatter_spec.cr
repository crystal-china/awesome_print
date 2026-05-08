require "./spec_helper"

private struct PointForAwesomePrint
  def initialize(@x : Int32, @y : Int32)
  end
end

private struct MethodLikeForAwesomePrint
  def initialize(@name : String)
  end

  def inspect(io : IO)
    io << "def " << @name << "()"
  end
end

private def strip_ansi(value : String) : String
  value.gsub(/\e\[[\d;]+m/, "")
end

describe AwesomePrint::Formatters::StructFormatter do
  it "formats structs with instance variables across multiple lines" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false)
    output = AwesomePrint::Formatters::StructFormatter.new(PointForAwesomePrint.new(3, 4), inspector).format

    output.should eq <<-TEXT
PointForAwesomePrint {
  @x = 3,
  @y = 4
}
TEXT
  end

  it "formats structs on a single line when multiline is disabled" do
    inspector = AwesomePrint::Inspector.new(multiline: false, colors_enabled: false)
    output = AwesomePrint::Formatters::StructFormatter.new(PointForAwesomePrint.new(3, 4), inspector).format

    output.should eq("PointForAwesomePrint { @x = 3, @y = 4 }")
  end

  it "sorts struct ivars by name when order is sorted" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false, order: :sorted)
    output = AwesomePrint::Formatters::StructFormatter.new(PointForAwesomePrint.new(3, 4), inspector).format

    output.index("@x = 3").not_nil!.should be < output.index("@y = 4").not_nil!
  end

  it "keeps struct wrapper text stable when colors are enabled" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2)
    output = AwesomePrint::Formatters::StructFormatter.new(PointForAwesomePrint.new(3, 4), inspector).format

    strip_ansi(output).should eq <<-TEXT
PointForAwesomePrint {
  @x = 3,
  @y = 4
}
TEXT
  end

  it "prefers a custom inspect representation for domain structs" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false, indent_size: 2)
    output = AwesomePrint::Formatters::StructFormatter.new(MethodLikeForAwesomePrint.new("ccc"), inspector).format

    output.should eq("def ccc()")
  end

  it "keeps raw mode on the ivar expansion path for custom inspect structs" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false, indent_size: 2, raw: true)
    output = AwesomePrint::Formatters::StructFormatter.new(MethodLikeForAwesomePrint.new("ccc"), inspector).format

    output.should eq <<-TEXT
MethodLikeForAwesomePrint {
  @name = "ccc"
}
TEXT
  end
end
