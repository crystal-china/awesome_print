require "./spec_helper"

describe AwesomePrint::Formatters::DirFormatter do
  it "formats dirs using inspect" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false)
    dir = Dir.new(".")
    output = AwesomePrint::Formatters::DirFormatter.new(dir, inspector).format

    output.should eq(dir.inspect)
  ensure
    dir.try &.close
  end

  it "uses dir-style colorization when colors are enabled" do
    inspector = AwesomePrint::Inspector.new
    dir = Dir.new(".")
    output = AwesomePrint::Formatters::DirFormatter.new(dir, inspector).format

    output.should eq(AwesomePrint::Colors.dir(dir.inspect))
  ensure
    dir.try &.close
  end
end
