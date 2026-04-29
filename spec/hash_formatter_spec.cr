require "./spec_helper"

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
end
