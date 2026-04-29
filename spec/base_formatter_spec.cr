require "./spec_helper"

private class TestFormatter < AwesomePrint::Formatters::BaseFormatter
  def expose_indent(n : Int32 = indentation) : String
    indent(n)
  end

  def expose_outdent : String
    outdent
  end

  def expose_align(value : String, width : Int32) : String
    align(value, width)
  end

  def expose_limited(data : Array(String), width : Int32, is_hash : Bool = false) : Array(String)
    limited(data, width, is_hash)
  end

  def expose_colorless(value : String) : String
    colorless(value)
  end

  def expose_colorize(value : String, type : Symbol) : String
    colorize(value, type)
  end
end

describe AwesomePrint::Formatters::BaseFormatter do
  it "manages indentation through the inspector" do
    formatter = TestFormatter.new(AwesomePrint::Inspector.new(indent_size: 2))

    formatter.indentation.should eq(0)

    formatter.indented do
      formatter.indentation.should eq(2)
      formatter.expose_indent.should eq("  ")
      formatter.expose_outdent.should eq("")
    end

    formatter.indentation.should eq(0)
  end

  it "limits long arrays using head and tail slices" do
    formatter = TestFormatter.new(AwesomePrint::Inspector.new(limit: 5))

    result = formatter.expose_limited(%w[a b c d e f g], 1)

    result.should eq(["a", "b", "[2] .. [4]", "f", "g"])
  end

  it "limits long hashes using a condensed middle marker" do
    formatter = TestFormatter.new(AwesomePrint::Inspector.new(limit: 5))

    result = formatter.expose_limited(["a: 1", "b: 2", "c: 3", "d: 4", "e: 5", "f: 6", "g: 7"], 1, true)

    result.should eq(["a: 1", "b: 2", "c: 3 .. e: 5", "f: 6", "g: 7"])
  end

  it "strips ansi color codes for width calculations" do
    formatter = TestFormatter.new(AwesomePrint::Inspector.new)
    colored = formatter.expose_colorize("value", :red)

    formatter.expose_colorless(colored).should eq("value")
    formatter.colorless_size(colored).should eq(5)
  end

  it "aligns plain values in multiline mode" do
    formatter = TestFormatter.new(AwesomePrint::Inspector.new)

    formatter.expose_align("x", 3).should eq("  x")
  end
end
