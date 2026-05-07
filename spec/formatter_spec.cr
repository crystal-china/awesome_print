require "./spec_helper"

private class HashLikeForAwesomePrint
  def initialize(@name : String, @rank : Int32)
  end

  def to_h
    {name: @name, rank: @rank}
  end
end

describe AwesomePrint::Formatter do
  it "formats nil, true, and false with semantic colors" do
    formatter = AwesomePrint::Formatter.new

    formatter.format(nil).should eq(AwesomePrint::Colors.nilclass("nil"))
    formatter.format(true).should eq(AwesomePrint::Colors.trueclass("true"))
    formatter.format(false).should eq(AwesomePrint::Colors.falseclass("false"))
  end

  it "formats hash-like objects through to_h by default" do
    formatter = AwesomePrint::Formatter.new(AwesomePrint::Inspector.new(colors_enabled: false, indent_size: 2))

    formatter.format(HashLikeForAwesomePrint.new("Diana", 1)).should eq <<-TEXT
{
  name: "Diana",
  rank: 1
}
TEXT
  end

  it "keeps hash-like objects on the object path when raw is enabled" do
    formatter = AwesomePrint::Formatter.new(AwesomePrint::Inspector.new(colors_enabled: false, indent_size: 2, raw: true))
    output = formatter.format(HashLikeForAwesomePrint.new("Diana", 1))

    output.should contain("#<HashLikeForAwesomePrint:0x")
    output.should contain("@name = \"Diana\"")
    output.should contain("@rank = 1")
  end
end
