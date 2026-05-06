require "./spec_helper"

private def strip_ansi(value : String) : String
  value.gsub(/\e\[[\d;]+m/, "")
end

describe AwesomePrint::Formatters::StaticArrayFormatter do
  it "formats static arrays using Crystal syntax" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false, indent_size: 2)
    output = AwesomePrint::Formatters::StaticArrayFormatter.new(StaticArray[1, 2, 3], inspector).format

    output.should eq <<-TEXT
StaticArray[
  [0] 1,
  [1] 2,
  [2] 3
]
TEXT
  end

  it "applies output limiting to long static arrays" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false, limit: 5, indent_size: 2)
    output = AwesomePrint::Formatters::StaticArrayFormatter.new(StaticArray[1, 2, 3, 4, 5, 6, 7], inspector).format

    output.should eq <<-TEXT
StaticArray[
  [0] 1,
  [1] 2,
  [2] .. [4],
  [5] 6,
  [6] 7
]
TEXT
  end

  it "keeps static array text stable when colors are enabled" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2)
    output = AwesomePrint::Formatters::StaticArrayFormatter.new(StaticArray[1, 2, 3], inspector).format

    strip_ansi(output).should eq <<-TEXT
StaticArray[
  [0] 1,
  [1] 2,
  [2] 3
]
TEXT
  end

  it "keeps static arrays on a single line when multiline is disabled" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false, multiline: false, indent_size: 2)
    output = AwesomePrint::Formatters::StaticArrayFormatter.new(StaticArray[1, 2, 3], inspector).format

    output.should eq("StaticArray[1, 2, 3]")
  end
end
