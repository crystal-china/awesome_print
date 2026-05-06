require "./spec_helper"

private def strip_ansi(value : String) : String
  value.gsub(/\e\[[\d;]+m/, "")
end

describe AwesomePrint::Formatters::RegexFormatter do
  it "formats regex literals" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false)
    output = AwesomePrint::Formatters::RegexFormatter.new(/foo/, inspector).format

    output.should eq("/foo/")
  end

  it "formats regexes with options" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false)
    output = AwesomePrint::Formatters::RegexFormatter.new(/foo/i, inspector).format

    output.should eq("/foo/i")
  end

  it "keeps regex text stable when colors are enabled" do
    inspector = AwesomePrint::Inspector.new
    output = AwesomePrint::Formatters::RegexFormatter.new(/foo/, inspector).format

    strip_ansi(output).should eq("/foo/")
  end
end
