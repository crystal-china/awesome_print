require "./spec_helper"

private enum DemoEnumForAwesomePrint
  Alpha
  Beta
end

private def strip_ansi(value : String) : String
  value.gsub(/\e\[[\d;]+m/, "")
end

describe AwesomePrint::Formatters::EnumFormatter do
  it "formats enums using Crystal enum syntax" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false)
    output = AwesomePrint::Formatters::EnumFormatter.new(DemoEnumForAwesomePrint::Alpha, inspector).format

    output.should eq("DemoEnumForAwesomePrint::Alpha")
  end

  it "keeps enum text stable when colors are enabled" do
    inspector = AwesomePrint::Inspector.new
    output = AwesomePrint::Formatters::EnumFormatter.new(DemoEnumForAwesomePrint::Alpha, inspector).format

    strip_ansi(output).should eq("DemoEnumForAwesomePrint::Alpha")
  end
end
