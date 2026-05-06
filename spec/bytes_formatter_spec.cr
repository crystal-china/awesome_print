require "./spec_helper"

private def strip_ansi(value : String) : String
  value.gsub(/\e\[[\d;]+m/, "")
end

describe AwesomePrint::Formatters::BytesFormatter do
  it "formats bytes using Crystal bytes syntax" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false)
    output = AwesomePrint::Formatters::BytesFormatter.new(Bytes[65, 66, 67], inspector).format

    output.should eq("Bytes[65, 66, 67]")
  end

  it "applies output limiting to long bytes" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false, limit: 5)
    output = AwesomePrint::Formatters::BytesFormatter.new(Bytes[1, 2, 3, 4, 5, 6, 7], inspector).format

    output.should eq("Bytes[1, 2, .., 6, 7]")
  end

  it "keeps bytes text stable when colors are enabled" do
    inspector = AwesomePrint::Inspector.new
    output = AwesomePrint::Formatters::BytesFormatter.new(Bytes[65, 66, 67], inspector).format

    strip_ansi(output).should eq("Bytes[65, 66, 67]")
  end
end
