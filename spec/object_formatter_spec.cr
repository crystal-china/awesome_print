require "./spec_helper"

private class PersonForAwesomePrint
  def initialize(@name : String, @rank : Int32, @admin : Bool, @very_long_status : String)
  end
end

private struct PointForAwesomePrint
  def initialize(@x : Int32, @y : Int32)
  end
end

describe AwesomePrint::Formatters::ObjectFormatter do
  it "formats reference objects with instance variables across multiple lines" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false)
    output = AwesomePrint::Formatters::ObjectFormatter.new(PersonForAwesomePrint.new("Diana", 1, false, "active"), inspector).format

    output.should contain("#<PersonForAwesomePrint:0x")
    output.should contain("             @name = \"Diana\"")
    output.should contain("             @rank = 1")
    output.should contain("            @admin = false")
    output.should contain("@very_long_status = \"active\"")
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

  it "keeps nested object closing braces indented to the current level" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false)
    output = AwesomePrint::Formatters::ArrayFormatter.new([PersonForAwesomePrint.new("Diana", 1, false, "active")], inspector).format

    output.should contain("  }>")
    output.should end_with("]")
  end

  it "keeps single line object output natural" do
    inspector = AwesomePrint::Inspector.new(multiline: false, colors_enabled: false)
    output = AwesomePrint::Formatters::ObjectFormatter.new(PersonForAwesomePrint.new("Diana", 1, false, "active"), inspector).format

    output.should contain("@name = \"Diana\"")
    output.should contain("@rank = 1")
    output.should_not contain("             @name")
  end

  it "sorts ivars by name when order is sorted" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false, order: :sorted)
    output = AwesomePrint::Formatters::ObjectFormatter.new(PersonForAwesomePrint.new("Diana", 1, false, "active"), inspector).format

    admin_index = output.index("@admin = false").not_nil!
    name_index = output.index("@name = \"Diana\"").not_nil!
    rank_index = output.index("@rank = 1").not_nil!

    admin_index.should be < name_index
    name_index.should be < rank_index
  end

  it "keeps sorted single line object output compact" do
    inspector = AwesomePrint::Inspector.new(multiline: false, colors_enabled: false, order: :sorted)
    output = AwesomePrint::Formatters::ObjectFormatter.new(PersonForAwesomePrint.new("Diana", 1, false, "active"), inspector).format

    output.should contain("@admin = false")
    output.should contain("@name = \"Diana\"")
    output.should contain("@rank = 1")
    output.should_not contain("\n")
    output.should_not contain("             @name")

    admin_index = output.index("@admin = false").not_nil!
    name_index = output.index("@name = \"Diana\"").not_nil!
    rank_index = output.index("@rank = 1").not_nil!

    admin_index.should be < name_index
    name_index.should be < rank_index
  end
end
