require "./spec_helper"

private def strip_ansi(value : String) : String
  value.gsub(/\e\[[\d;]+m/, "")
end

describe AwesomePrint::Formatters::FileFormatter do
  it "formats files using Crystal inspect text" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false)

    File.tempfile("ap-demo") do |file|
      output = AwesomePrint::Formatters::FileFormatter.new(file, inspector).format
      output.should eq(file.inspect)
    end
  end

  it "keeps file text stable when colors are enabled" do
    inspector = AwesomePrint::Inspector.new

    File.tempfile("ap-demo") do |file|
      output = AwesomePrint::Formatters::FileFormatter.new(file, inspector).format
      strip_ansi(output).should eq(file.inspect)
    end
  end
end
