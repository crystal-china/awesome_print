require "./spec_helper"

describe AwesomePrint::Formatters::TimeFormatter do
  it "formats time values using inspect" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false)
    value = Time.utc(2026, 5, 6, 12, 34, 56)
    output = AwesomePrint::Formatters::TimeFormatter.new(value, inspector).format

    output.should eq(value.inspect)
  end

  it "uses time-style colorization when colors are enabled" do
    inspector = AwesomePrint::Inspector.new
    value = Time.utc(2026, 5, 6, 12, 34, 56)
    output = AwesomePrint::Formatters::TimeFormatter.new(value, inspector).format

    output.should eq(AwesomePrint::Colors.time(value.inspect))
  end
end
