require "./spec_helper"

describe AwesomePrint::Formatter do
  it "formats nil, true, and false with semantic colors" do
    formatter = AwesomePrint::Formatter.new

    formatter.format(nil).should eq(AwesomePrint::Colors.nilclass("nil"))
    formatter.format(true).should eq(AwesomePrint::Colors.trueclass("true"))
    formatter.format(false).should eq(AwesomePrint::Colors.falseclass("false"))
  end
end
