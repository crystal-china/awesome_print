require "./spec_helper"

private def strip_ansi(value : String) : String
  value.gsub(/\e\[[\d;]+m/, "")
end

describe AwesomePrint::Formatters::TupleFormatter do
  it "formats tuples across multiple lines with indexes" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false)
    output = AwesomePrint::Formatters::TupleFormatter.new({1, 2, 3}, inspector).format

    output.should eq <<-TEXT
{
  [0] 1,
  [1] 2,
  [2] 3
}
TEXT
  end

  it "formats tuples on a single line when multiline is disabled" do
    inspector = AwesomePrint::Inspector.new(multiline: false, colors_enabled: false)
    output = AwesomePrint::Formatters::TupleFormatter.new({1, 2, 3}, inspector).format

    output.should eq("{ 1, 2, 3 }")
  end

  it "applies output limiting to long single line tuples" do
    inspector = AwesomePrint::Inspector.new(multiline: false, limit: 5, colors_enabled: false)
    output = AwesomePrint::Formatters::TupleFormatter.new({1, 2, 3, 4, 5, 6, 7}, inspector).format

    output.should eq("{ 1, 2, .., 6, 7 }")
  end

  it "keeps tuple wrapper text stable when colors are enabled" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2)
    output = AwesomePrint::Formatters::TupleFormatter.new({1, 2, 3}, inspector).format

    strip_ansi(output).should eq <<-TEXT
{
  [0] 1,
  [1] 2,
  [2] 3
}
TEXT
  end
end
