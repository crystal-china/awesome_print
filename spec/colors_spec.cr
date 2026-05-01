require "./spec_helper"

describe AwesomePrint::Colors do
  it "returns the original string when disabled" do
    AwesomePrint::Colors.red("value", false).should eq("value")
    AwesomePrint::Colors.apply(:green, "value", false).should eq("value")
  end

  it "returns the original string for unknown colors" do
    AwesomePrint::Colors.apply(:missing, "value").should eq("value")
  end

  it "applies ansi colors for known names" do
    AwesomePrint::Colors.red("value").should contain("\e[")
    AwesomePrint::Colors.purpleish("value").should contain("\e[")
    AwesomePrint::Colors.pale("value").should contain("\e[")
  end

  it "applies ansi colors for semantic formatter names" do
    AwesomePrint::Colors.string("value").should contain("\e[")
    AwesomePrint::Colors.symbol("value").should contain("\e[")
    AwesomePrint::Colors.number("value").should contain("\e[")
    AwesomePrint::Colors.keyword("value").should contain("\e[")
    AwesomePrint::Colors.nilclass("value").should contain("\e[")
    AwesomePrint::Colors.trueclass("value").should contain("\e[")
    AwesomePrint::Colors.falseclass("value").should contain("\e[")
    AwesomePrint::Colors.variable("value").should contain("\e[")
    AwesomePrint::Colors.class("value").should contain("\e[")
    AwesomePrint::Colors.array("value").should contain("\e[")
    AwesomePrint::Colors.hash("value").should contain("\e[")
  end

  it "uses distinct ansi colors for array, number, and class tokens" do
    AwesomePrint::Colors.array("value").should_not eq(AwesomePrint::Colors.number("value"))
    AwesomePrint::Colors.array("value").should_not eq(AwesomePrint::Colors.class("value"))
    AwesomePrint::Colors.number("value").should_not eq(AwesomePrint::Colors.class("value"))
  end

  it "renders array tokens brighter than plain white" do
    AwesomePrint::Colors.array("value").should_not eq(AwesomePrint::Colors.white("value"))
  end

  it "uses awesome_print style colors for nil, true, and false" do
    AwesomePrint::Colors.nilclass("nil").should eq(AwesomePrint::Colors.red("nil"))
    AwesomePrint::Colors.trueclass("true").should eq(AwesomePrint::Colors.green("true"))
    AwesomePrint::Colors.falseclass("false").should eq(AwesomePrint::Colors.red("false"))
  end
end
