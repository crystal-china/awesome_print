require "./spec_helper"

private def strip_ansi(value : String) : String
  value.gsub(/\e\[[\d;]+m/, "")
end

describe AwesomePrint::Formatters::PathFormatter do
  it "formats paths using Crystal path syntax" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false)
    output = AwesomePrint::Formatters::PathFormatter.new(Path["foo/bar"], inspector).format

    output.should eq(%(Path["foo/bar"]))
  end

  it "keeps path text stable when colors are enabled" do
    inspector = AwesomePrint::Inspector.new
    output = AwesomePrint::Formatters::PathFormatter.new(Path["foo/bar"], inspector).format

    strip_ansi(output).should eq(%(Path["foo/bar"]))
  end
end
