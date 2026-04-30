require "./spec_helper"

private class PersonForApMacro
  def initialize(@name : String, @rank : Int32, @admin : Bool, @very_long_status : String)
  end
end

describe AwesomePrint do
  it "prints file, line, expression, pretty value, and type" do
    io = IO::Memory.new
    AwesomePrint.output = io

    value = ap!([1, 2, 3])

    value.should eq([1, 2, 3])

    output = io.to_s
    output.should contain("spec/awesome_print_spec.cr")
    output.should contain("[1, 2, 3] =")
    output.should contain("[0] 1")
    output.should contain("[1] 2")
    output.should contain("[2] 3")
    output.should contain("(Array(Int32))")
  end

  it "returns the original value from expressions" do
    io = IO::Memory.new
    AwesomePrint.output = io

    value = ap!(1 + 2)

    value.should eq(3)
    io.to_s.should contain("1 + 2")
    io.to_s.should contain("(Int32)")
  end

  it "prints each argument and returns them as a tuple when given multiple expressions" do
    io = IO::Memory.new
    AwesomePrint.output = io

    values = ap!(1, "two")

    values.should eq({1, "two"})

    output = io.to_s
    output.should contain("1 =")
    output.should contain("\"two\" =")
    output.should contain("(String)")
  end

  it "passes formatter options through ap!" do
    io = IO::Memory.new
    AwesomePrint.output = io
    person = PersonForApMacro.new("Diana", 1, false, "active")

    value = ap!(person, order: :sorted)

    value.should be(person)
    output = io.to_s
    admin_index = output.index("@admin = false").not_nil!
    name_index = output.index("@name = \"Diana\"").not_nil!

    admin_index.should be < name_index
  end

  it "passes multiline options through ap!" do
    io = IO::Memory.new
    AwesomePrint.output = io

    value = ap!([1, 2, 3], multiline: false)

    value.should eq([1, 2, 3])
    io.to_s.should contain("[ 1, 2, 3 ]")
  end

  it "passes limit options through ap!" do
    io = IO::Memory.new
    AwesomePrint.output = io

    value = ap!([1, 2, 3, 4, 5, 6, 7], limit: 5)

    value.should eq([1, 2, 3, 4, 5, 6, 7])
    output = io.to_s
    output.should contain("[0] 1")
    output.should contain("[1] 2")
    output.should contain("[2] .. [4]")
    output.should contain("[5] 6")
    output.should contain("[6] 7")
  end
end
