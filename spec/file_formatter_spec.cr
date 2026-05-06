require "./spec_helper"

describe AwesomePrint::Formatters::FileFormatter do
  it "formats files using inspect" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false)

    File.tempfile("ap-demo") do |file|
      output = AwesomePrint::Formatters::FileFormatter.new(file, inspector).format
      output.should eq(file.inspect)
    end
  end

  it "uses file-style colorization when colors are enabled" do
    inspector = AwesomePrint::Inspector.new

    File.tempfile("ap-demo") do |file|
      output = AwesomePrint::Formatters::FileFormatter.new(file, inspector).format
      output.should eq(AwesomePrint::Colors.file(file.inspect))
    end
  end
end
