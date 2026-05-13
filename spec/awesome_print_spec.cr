require "./spec_helper"

private class PersonForApMacro
  def initialize(@name : String, @rank : Int32, @admin : Bool, @very_long_status : String)
  end
end

private class ExplosiveForApMacro
  def to_h
    raise "omitted element should not be formatted"
  end
end

private def strip_ansi(value : String) : String
  value.gsub(/\e\[[\d;]+m/, "")
end

describe AwesomePrint do
  it "prints file, line, expression, pretty value, and type" do
    io = IO::Memory.new
    AwesomePrint.output = io

    value = ap!([1, 2, 3])

    value.should eq([1, 2, 3])

    output = strip_ansi(io.to_s)
    output.should contain("spec/awesome_print_spec.cr:")
    output.should contain("[1, 2, 3]")
    output.should contain("(Array(Int32))")
    output.should contain("[0] 1")
    output.should contain("[1] 2")
    output.should contain("[2] 3")
  end

  it "returns the original value from expressions" do
    io = IO::Memory.new
    AwesomePrint.output = io

    value = ap!(1 + 2)

    value.should eq(3)
    output = strip_ansi(io.to_s)
    output.should contain("1 + 2")
    output.should contain("(Int32)")
  end

  it "prints each argument and returns them as a tuple when given multiple expressions" do
    io = IO::Memory.new
    AwesomePrint.output = io

    values = ap!(1, "two")

    values.should eq({1, "two"})

    output = strip_ansi(io.to_s)
    output.should contain("1")
    output.should contain("(Int32)")
    output.should contain("\"two\"")
    output.should contain("(String)")
  end

  it "passes formatter options through ap!" do
    io = IO::Memory.new
    AwesomePrint.output = io
    person = PersonForApMacro.new("Diana", 1, false, "active")

    value = ap!(person, order: :sorted)

    value.should be(person)
    output = strip_ansi(io.to_s)
    admin_index = output.index("@admin = false").not_nil!
    name_index = output.index("@name = \"Diana\"").not_nil!

    admin_index.should be < name_index
  end

  it "passes object_id options through ap!" do
    io = IO::Memory.new
    AwesomePrint.output = io
    person = PersonForApMacro.new("Diana", 1, false, "active")

    value = ap!(person, object_id: false)

    value.should be(person)
    output = strip_ansi(io.to_s)
    output.should contain("#<PersonForApMacro {")
    output.should_not contain(":0x")
  end

  it "passes multiline options through ap!" do
    io = IO::Memory.new
    AwesomePrint.output = io

    value = ap!([1, 2, 3], multiline: false)

    value.should eq([1, 2, 3])
    strip_ansi(io.to_s).should contain("[ 1, 2, 3 ]")
  end

  it "passes limit options through ap!" do
    io = IO::Memory.new
    AwesomePrint.output = io

    value = ap!([1, 2, 3, 4, 5, 6, 7], limit: 5)

    value.should eq([1, 2, 3, 4, 5, 6, 7])
    output = strip_ansi(io.to_s)
    output.should contain("[0] 1")
    output.should contain("[1] 2")
    output.should contain("[2] .. [4]")
    output.should contain("[5] 6")
    output.should contain("[6] 7")
  end

  it "does not format omitted elements when ap! prints a limited array" do
    io = IO::Memory.new
    AwesomePrint.output = io

    value = ap!([1, 2, ExplosiveForApMacro.new, ExplosiveForApMacro.new, ExplosiveForApMacro.new, 6, 7], limit: 5)

    value.size.should eq(7)
    output = strip_ansi(io.to_s)
    output.should contain("[0] 1")
    output.should contain("[1] 2")
    output.should contain("[2] .. [4]")
    output.should contain("[5] 6")
    output.should contain("[6] 7")
  end

  it "applies options to every argument when given multiple expressions" do
    io = IO::Memory.new
    AwesomePrint.output = io

    values = ap!([3, 1, 2], {"z" => 1, "a" => 2}, multiline: false, order: :sorted)

    values.should eq({[3, 1, 2], {"z" => 1, "a" => 2}})
    output = strip_ansi(io.to_s)
    output.should contain("[ 3, 1, 2 ]")
    output.should contain(%({ "a" => 2, "z" => 1 }))
  end

  it "returns a formatted string without printing when using AwesomePrint.format" do
    io = IO::Memory.new
    AwesomePrint.output = io

    output = AwesomePrint.format([1, 2, 3], multiline: false)

    output.should eq("[ 1, 2, 3 ]")
    io.to_s.should eq("")
  end

  it "returns plain text by default when using AwesomePrint.format" do
    output = AwesomePrint.format([1, 2, 3])

    output.should eq("[\n    [0] 1,\n    [1] 2,\n    [2] 3\n]")
  end

  it "uses the same default indentation for ap! and AwesomePrint.format" do
    io = IO::Memory.new
    AwesomePrint.output = io

    ap!([1, 2, 3])
    ap_output = strip_ansi(io.to_s)
    formatted = AwesomePrint.format([1, 2, 3])

    ap_output.should contain("[\n    [0] 1,\n    [1] 2,\n    [2] 3\n]")
    formatted.should eq("[\n    [0] 1,\n    [1] 2,\n    [2] 3\n]")
  end

  it "keeps streamed output consistent with formatted strings" do
    io = IO::Memory.new
    inspector = AwesomePrint::Inspector.new(colors_enabled: false, indent_size: 2, object_id: false)
    person = PersonForApMacro.new("Diana", 1, false, "active")
    value = [person, {name: "Diana", rank: 1}]

    inspector.write_awesome(io, value)

    io.to_s.should eq(inspector.awesome(value))
  end

  it "accepts an explicit inspector when using AwesomePrint.format" do
    inspector = AwesomePrint::Inspector.new(multiline: false, colors_enabled: false, order: :sorted)

    output = AwesomePrint.format({"z" => 1, "a" => 2}, inspector)

    output.should eq(%({ "a" => 2, "z" => 1 }))
  end

  it "allows colors to be explicitly enabled for AwesomePrint.format" do
    output = AwesomePrint.format([1, 2, 3], multiline: false, colors_enabled: true)

    output.should_not eq("[ 1, 2, 3 ]")
    strip_ansi(output).should eq("[ 1, 2, 3 ]")
  end

  it "passes object_id options through AwesomePrint.format" do
    person = PersonForApMacro.new("Diana", 1, false, "active")
    output = AwesomePrint.format(person, object_id: false)

    output.should contain("#<PersonForApMacro {")
    output.should_not contain(":0x")
  end
end
