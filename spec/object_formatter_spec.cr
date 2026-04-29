require "./spec_helper"

private class PersonForAwesomePrint
  def initialize(@name : String, @rank : Int32, @admin : Bool)
  end
end

private struct PointForAwesomePrint
  def initialize(@x : Int32, @y : Int32)
  end
end

describe AwesomePrint::Formatters::ObjectFormatter do
  it "formats reference objects with instance variables across multiple lines" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false)
    output = AwesomePrint::Formatters::ObjectFormatter.new(PersonForAwesomePrint.new("Diana", 1, false), inspector).format

    output.should contain("#<PersonForAwesomePrint:0x")
    output.should contain("@name = \"Diana\"")
    output.should contain("@rank = 1")
    output.should contain("@admin = false")
    output.should contain("}>")
  end

  it "formats structs with instance variables across multiple lines" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false)
    output = AwesomePrint::Formatters::ObjectFormatter.new(PointForAwesomePrint.new(3, 4), inspector).format

    output.should eq <<-TEXT
PointForAwesomePrint {
  @x = 3,
  @y = 4
}
TEXT
  end

  it "falls back to pretty_inspect for ivar-less values" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false)
    output = AwesomePrint::Formatters::ObjectFormatter.new(42, inspector).format

    output.should eq("42")
  end
end
