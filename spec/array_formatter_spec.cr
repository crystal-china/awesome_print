require "./spec_helper"

describe AwesomePrint::Formatters::ArrayFormatter do
  it "formats arrays across multiple lines with indexes" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false)
    output = AwesomePrint::Formatters::ArrayFormatter.new([1, 2, 3], inspector).format

    output.should eq <<-TEXT
[
  [0] 1,
  [1] 2,
  [2] 3
]
TEXT
  end

  it "formats arrays on a single line when multiline is disabled" do
    inspector = AwesomePrint::Inspector.new(multiline: false, colors_enabled: false)
    output = AwesomePrint::Formatters::ArrayFormatter.new([1, 2, 3], inspector).format

    output.should eq("[ 1, 2, 3 ]")
  end

  it "applies output limiting to long arrays" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, limit: 5, colors_enabled: false)
    output = AwesomePrint::Formatters::ArrayFormatter.new([1, 2, 3, 4, 5, 6, 7], inspector).format

    output.should eq <<-TEXT
[
  [0] 1,
  [1] 2,
  [2] .. [4],
  [5] 6,
  [6] 7
]
TEXT
  end
end
