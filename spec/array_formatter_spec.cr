require "./spec_helper"

private def strip_ansi(value : String) : String
  value.gsub(/\e\[[\d;]+m/, "")
end

private class ExplosiveToH
  def to_h
    raise "omitted element should not be formatted"
  end
end

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

  it "applies output limiting to long single line arrays" do
    inspector = AwesomePrint::Inspector.new(multiline: false, limit: 5, colors_enabled: false)
    output = AwesomePrint::Formatters::ArrayFormatter.new([1, 2, 3, 4, 5, 6, 7], inspector).format

    output.should eq("[ 1, 2, .., 6, 7 ]")
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

  it "does not format omitted multiline elements when limit is applied" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, limit: 5, colors_enabled: false)
    output = AwesomePrint::Formatters::ArrayFormatter.new([1, 2, ExplosiveToH.new, ExplosiveToH.new, ExplosiveToH.new, 6, 7], inspector).format

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

  it "does not format omitted single line elements when limit is applied" do
    inspector = AwesomePrint::Inspector.new(multiline: false, limit: 5, colors_enabled: false)
    output = AwesomePrint::Formatters::ArrayFormatter.new([1, 2, ExplosiveToH.new, ExplosiveToH.new, ExplosiveToH.new, 6, 7], inspector).format

    output.should eq("[ 1, 2, .., 6, 7 ]")
  end

  it "keeps nested array closing brackets indented to the current level" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false)
    output = AwesomePrint::Formatters::ArrayFormatter.new([1, [2, 3], 4], inspector).format

    output.should eq <<-TEXT
[
  [0] 1,
  [1] [
    [0] 2,
    [1] 3
  ],
  [2] 4
]
TEXT
  end

  it "keeps array wrapper text stable when colors are enabled" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2)
    output = AwesomePrint::Formatters::ArrayFormatter.new([1, 2, 3], inspector).format

    strip_ansi(output).should eq <<-TEXT
[
  [0] 1,
  [1] 2,
  [2] 3
]
TEXT
  end
end
