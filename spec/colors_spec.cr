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
end
