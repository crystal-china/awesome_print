require "./spec_helper"

private class ManyFieldsForAwesomePrint
  def initialize(
    @a : Int32,
    @b : Int32,
    @c : Int32,
    @d : Int32,
    @e : Int32,
    @f : Int32,
    @g : Int32
  )
  end
end

describe AwesomePrint::Formatters::ObjectFormatter do
  it "applies limit to multiline object fields" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false, limit: 5)
    object = ManyFieldsForAwesomePrint.new(1, 2, 3, 4, 5, 6, 7)
    output = AwesomePrint::Formatters::ObjectFormatter.new(object, inspector).format

    output.should contain("@a = 1")
    output.should contain("@b = 2")
    output.should contain("@c = 3 .. @e = 5")
    output.should contain("@f = 6")
    output.should contain("@g = 7")
  end
end
