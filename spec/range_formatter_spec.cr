require "./spec_helper"

describe AwesomePrint::Formatters::RangeFormatter do
  it "formats inclusive numeric ranges" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false)
    output = AwesomePrint::Formatters::RangeFormatter.new(1..3, inspector).format

    output.should eq("1..3")
  end

  it "formats exclusive numeric ranges" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false)
    output = AwesomePrint::Formatters::RangeFormatter.new(1...3, inspector).format

    output.should eq("1...3")
  end

  it "formats string ranges with value colors intact" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false)
    output = AwesomePrint::Formatters::RangeFormatter.new("a".."z", inspector).format

    output.should eq(%("a".."z"))
  end
end
