require "./spec_helper"

private def strip_ansi(value : String) : String
  value.gsub(/\e\[[\d;]+m/, "")
end

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

  it "keeps range text stable when colors are enabled" do
    inspector = AwesomePrint::Inspector.new
    output = AwesomePrint::Formatters::RangeFormatter.new("a".."z", inspector).format

    strip_ansi(output).should eq(%("a".."z"))
  end

  it "colors range values and operator separately" do
    inspector = AwesomePrint::Inspector.new
    output = AwesomePrint::Formatters::RangeFormatter.new(1...3, inspector).format

    output.should contain(AwesomePrint::Colors.number("1"))
    output.should contain(AwesomePrint::Colors.hash("..."))
    output.should contain(AwesomePrint::Colors.number("3"))
  end
end
