require "./spec_helper"

describe AwesomePrint do
  it "prints file, line, expression, pretty value, and type" do
    io = IO::Memory.new
    AwesomePrint.output = io

    value = ap!([1, 2, 3])

    value.should eq([1, 2, 3])

    output = io.to_s
    output.should contain("spec/awesome_print_spec.cr")
    output.should contain("[1, 2, 3] =")
    output.should contain("[")
    output.should contain("1,")
    output.should contain("2,")
    output.should contain("3")
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
end
