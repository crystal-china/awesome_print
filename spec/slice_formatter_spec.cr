require "./spec_helper"

private def strip_ansi(value : String) : String
  value.gsub(/\e\[[\d;]+m/, "")
end

describe AwesomePrint::Formatters::SliceFormatter do
  it "formats slices using Crystal slice syntax" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false, indent_size: 2)
    output = AwesomePrint::Formatters::SliceFormatter.new(Slice[1, 2, 3], inspector).format

    output.should eq <<-TEXT
Slice[
  [0] 1,
  [1] 2,
  [2] 3
]
TEXT
  end

  it "applies output limiting to long slices" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false, indent_size: 2, limit: 5)
    output = AwesomePrint::Formatters::SliceFormatter.new(Slice[1, 2, 3, 4, 5, 6, 7], inspector).format

    output.should eq <<-TEXT
Slice[
  [0] 1,
  [1] 2,
  [2] .. [4],
  [5] 6,
  [6] 7
]
TEXT
  end

  it "keeps slices on a single line when multiline is disabled" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false, multiline: false)
    output = AwesomePrint::Formatters::SliceFormatter.new(Slice[1, 2, 3], inspector).format

    output.should eq("Slice[1, 2, 3]")
  end

  it "keeps slice text stable when colors are enabled" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2)
    output = AwesomePrint::Formatters::SliceFormatter.new(Slice[1, 2, 3], inspector).format

    strip_ansi(output).should eq <<-TEXT
Slice[
  [0] 1,
  [1] 2,
  [2] 3
]
TEXT
  end
end
