require "./spec_helper"

private def strip_ansi(value : String) : String
  value.gsub(/\e\[[\d;]+m/, "")
end

describe AwesomePrint::Formatters::DirFormatter do
  it "formats dirs using Crystal inspect text" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false)
    dir = Dir.new(".")
    output = AwesomePrint::Formatters::DirFormatter.new(dir, inspector).format

    output.should eq(dir.inspect)
  ensure
    dir.try &.close
  end

  it "keeps dir text stable when colors are enabled" do
    inspector = AwesomePrint::Inspector.new
    dir = Dir.new(".")
    output = AwesomePrint::Formatters::DirFormatter.new(dir, inspector).format

    strip_ansi(output).should eq(dir.inspect)
  ensure
    dir.try &.close
  end
end
