require "./spec_helper"

private class HashKeyForAwesomePrint
  def initialize(@id : Int32)
  end
end

private def strip_ansi(value : String) : String
  value.gsub(/\e\[[\d;]+m/, "")
end

private struct StructKeyForAwesomePrint
  def initialize(@x : Int32, @y : Int32)
  end
end

describe AwesomePrint::Formatters::HashFormatter do
  it "formats symbol-keyed hashes across multiple lines" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false)
    output = AwesomePrint::Formatters::HashFormatter.new({:name => "Diana", :rank => 1}, inspector).format

    output.should eq <<-TEXT
{
  name: "Diana",
  rank: 1
}
TEXT
  end

  it "formats non-symbol keys with rockets" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false)
    output = AwesomePrint::Formatters::HashFormatter.new({"name" => "Diana", "rank" => 1}, inspector).format

    output.should eq <<-TEXT
{
  "name" => "Diana",
  "rank" => 1
}
TEXT
  end

  it "formats hashes on a single line when multiline is disabled" do
    inspector = AwesomePrint::Inspector.new(multiline: false, colors_enabled: false)
    output = AwesomePrint::Formatters::HashFormatter.new({:name => "Diana", :rank => 1}, inspector).format

    output.should eq(%({ name: "Diana", rank: 1 }))
  end

  it "formats symbol keys with rockets when hash_format is rocket" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false, hash_format: :rocket)
    output = AwesomePrint::Formatters::HashFormatter.new({:id => 1, :display_name => "Diana"}, inspector).format

    output.should contain(":id => 1")
    output.should contain(":display_name => \"Diana\"")
    output.index(":id => 1").not_nil!.should be < output.index(":display_name => \"Diana\"").not_nil!
  end

  it "formats string and symbol keys with json colons when hash_format is json" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false, hash_format: :json)
    output = AwesomePrint::Formatters::HashFormatter.new({:id => 1, "display_name" => "Diana"}, inspector).format

    output.should contain("\"id\": 1")
    output.should contain("\"display_name\": \"Diana\"")
    output.index("\"id\": 1").not_nil!.should be < output.index("\"display_name\": \"Diana\"").not_nil!
  end

  it "keeps sorted single line hashes compact" do
    inspector = AwesomePrint::Inspector.new(multiline: false, colors_enabled: false, order: :sorted)
    output = AwesomePrint::Formatters::HashFormatter.new({"z" => 1, "a" => 2, "m" => 3}, inspector).format

    output.should eq(%({ "a" => 2, "m" => 3, "z" => 1 }))
  end

  it "applies output limiting to long single line hashes" do
    inspector = AwesomePrint::Inspector.new(multiline: false, limit: 5, colors_enabled: false, order: :sorted)
    output = AwesomePrint::Formatters::HashFormatter.new({"g" => 7, "b" => 2, "f" => 6, "a" => 1, "e" => 5, "c" => 3, "d" => 4}, inspector).format

    output.should eq(%({ "a" => 1, "b" => 2, .., "f" => 6, "g" => 7 }))
  end

  it "applies output limiting to long hashes" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, limit: 5, colors_enabled: false)
    output = AwesomePrint::Formatters::HashFormatter.new({:a => 1, :b => 2, :c => 3, :d => 4, :e => 5, :f => 6, :g => 7}, inspector).format

    output.should eq <<-TEXT
{
  a: 1,
  b: 2,
  c: 3 .. e: 5,
  f: 6,
  g: 7
}
TEXT
  end

  it "preserves insertion order when order is natural" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false, order: :natural)
    output = AwesomePrint::Formatters::HashFormatter.new({"z" => 1, "a" => 2, "m" => 3}, inspector).format

    output.should eq <<-TEXT
{
  "z" => 1,
  "a" => 2,
  "m" => 3
}
TEXT
  end

  it "sorts keys when order is sorted" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false, order: :sorted)
    output = AwesomePrint::Formatters::HashFormatter.new({"z" => 1, "a" => 2, "m" => 3}, inspector).format

    output.should eq <<-TEXT
{
  "a" => 2,
  "m" => 3,
  "z" => 1
}
TEXT
  end

  it "keeps sorted hashes stable when limit is applied" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false, limit: 5, order: :sorted)
    output = AwesomePrint::Formatters::HashFormatter.new({"g" => 7, "b" => 2, "f" => 6, "a" => 1, "e" => 5, "c" => 3, "d" => 4}, inspector).format

    output.should eq <<-TEXT
{
  "a" => 1,
  "b" => 2,
  "c" => 3 .. "e" => 5,
  "f" => 6,
  "g" => 7
}
TEXT
  end

  it "formats non-string scalar keys on a single line" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false)
    output = AwesomePrint::Formatters::HashFormatter.new({1 => "one", true => "yes"}, inspector).format

    output.should eq <<-TEXT
{
     1 => "one",
  true => "yes"
}
TEXT
  end

  it "keeps hash wrapper text stable when colors are enabled" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2)
    output = AwesomePrint::Formatters::HashFormatter.new({"name" => "Diana", "rank" => 1}, inspector).format

    strip_ansi(output).should eq <<-TEXT
{
  "name" => "Diana",
  "rank" => 1
}
TEXT
  end

  it "formats object keys on a single line" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false)
    output = AwesomePrint::Formatters::HashFormatter.new({HashKeyForAwesomePrint.new(1) => "one"}, inspector).format

    output.should contain("#<HashKeyForAwesomePrint:0x")
    output.should contain("@id = 1")
    output.should contain(" => \"one\"")
    output.should_not contain("\n  @id = 1\n}> =>")
  end

  it "formats tuple, named tuple, and struct keys on a single line" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false)
    output = AwesomePrint::Formatters::HashFormatter.new({
      {1, 2} => "tuple",
      ({name: "Diana", rank: 1}) => "named",
      StructKeyForAwesomePrint.new(3, 4) => "struct",
    }, inspector).format

    output.should contain("{ 1, 2 } => \"tuple\"")
    output.should contain("{ name: \"Diana\", rank: 1 } => \"named\"")
    output.should contain("StructKeyForAwesomePrint { @x = 3, @y = 4 } => \"struct\"")
  end
end
