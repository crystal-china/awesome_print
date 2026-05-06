require "./spec_helper"

describe AwesomePrint::Formatters::SetFormatter do
  it "formats sets across multiple lines without indexes" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false)
    output = AwesomePrint::Formatters::SetFormatter.new(Set{1, 2, 3}, inspector).format

    output.should eq <<-TEXT
(
  1,
  2,
  3
)
TEXT
  end

  it "formats sets on a single line when multiline is disabled" do
    inspector = AwesomePrint::Inspector.new(multiline: false, colors_enabled: false)
    output = AwesomePrint::Formatters::SetFormatter.new(Set{1, 2, 3}, inspector).format

    output.should eq("( 1, 2, 3 )")
  end

  it "applies output limiting to long single line sets" do
    inspector = AwesomePrint::Inspector.new(multiline: false, limit: 5, colors_enabled: false)
    output = AwesomePrint::Formatters::SetFormatter.new(Set{1, 2, 3, 4, 5, 6, 7}, inspector).format

    output.should eq("( 1, 2, .., 6, 7 )")
  end

  it "applies output limiting to long sets without synthetic indexes" do
    inspector = AwesomePrint::Inspector.new(indent_size: 2, limit: 5, colors_enabled: false)
    output = AwesomePrint::Formatters::SetFormatter.new(Set{1, 2, 3, 4, 5, 6, 7}, inspector).format

    output.should eq <<-TEXT
(
  1,
  2,
  ..,
  6,
  7
)
TEXT
  end
end
