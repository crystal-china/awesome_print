require "./spec_helper"

describe AwesomePrint::Formatters::NamedTupleFormatter do
  it "formats named tuples across multiple lines" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false)
    output = AwesomePrint::Formatters::NamedTupleFormatter.new({name: "Diana", rank: 1}, inspector).format

    output.should eq <<-TEXT
{
  name: "Diana",
  rank: 1
}
TEXT
  end

  it "formats named tuples on a single line when multiline is disabled" do
    inspector = AwesomePrint::Inspector.new(multiline: false, colors_enabled: false)
    output = AwesomePrint::Formatters::NamedTupleFormatter.new({name: "Diana", rank: 1}, inspector).format

    output.should eq(%({ name: "Diana", rank: 1 }))
  end

  it "formats named tuples with rockets when hash_format is rocket" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false, hash_format: :rocket)
    output = AwesomePrint::Formatters::NamedTupleFormatter.new({id: 1, display_name: "Diana"}, inspector).format

    output.should contain(":id => 1")
    output.should contain(":display_name => \"Diana\"")
    output.index(":id => 1").not_nil!.should be < output.index(":display_name => \"Diana\"").not_nil!
  end

  it "formats named tuples with json colons when hash_format is json" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false, hash_format: :json)
    output = AwesomePrint::Formatters::NamedTupleFormatter.new({id: 1, display_name: "Diana"}, inspector).format

    output.should contain("\"id\": 1")
    output.should contain("\"display_name\": \"Diana\"")
    output.index("\"id\": 1").not_nil!.should be < output.index("\"display_name\": \"Diana\"").not_nil!
  end

  it "keeps sorted single line named tuples compact" do
    inspector = AwesomePrint::Inspector.new(multiline: false, colors_enabled: false, order: :sorted)
    output = AwesomePrint::Formatters::NamedTupleFormatter.new({z: 1, a: 2, m: 3}, inspector).format

    output.should eq(%({ a: 2, m: 3, z: 1 }))
  end

  it "applies output limiting to long single line named tuples" do
    inspector = AwesomePrint::Inspector.new(multiline: false, limit: 5, colors_enabled: false, order: :sorted)
    output = AwesomePrint::Formatters::NamedTupleFormatter.new({g: 7, b: 2, f: 6, a: 1, e: 5, c: 3, d: 4}, inspector).format

    output.should eq(%({ a: 1, b: 2, .., f: 6, g: 7 }))
  end

  it "applies output limiting to long named tuples" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, limit: 5, colors_enabled: false)
    output = AwesomePrint::Formatters::NamedTupleFormatter.new({a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7}, inspector).format

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

  it "keeps sorted named tuples stable when limit is applied" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, limit: 5, colors_enabled: false, order: :sorted)
    output = AwesomePrint::Formatters::NamedTupleFormatter.new({g: 7, b: 2, f: 6, a: 1, e: 5, c: 3, d: 4}, inspector).format

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
end
