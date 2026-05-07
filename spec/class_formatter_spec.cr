require "./spec_helper"

private def strip_ansi(value : String) : String
  value.gsub(/\e\[[\d;]+m/, "")
end

describe AwesomePrint::Formatters::ClassFormatter do
  it "formats class objects using Crystal type syntax" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false)
    output = AwesomePrint::Formatters::ClassFormatter.new(String, inspector).format

    output.should eq("String")
  end

  it "keeps class text stable when colors are enabled" do
    inspector = AwesomePrint::Inspector.new
    output = AwesomePrint::Formatters::ClassFormatter.new(Array(Int32), inspector).format

    strip_ansi(output).should eq("Array(Int32)")
  end
end
