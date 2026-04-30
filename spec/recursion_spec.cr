require "./spec_helper"

private class RecursivePersonForAwesomePrint
  property friend : RecursivePersonForAwesomePrint?

  def initialize(@name : String)
  end
end

describe AwesomePrint::Inspector do
  it "replaces recursive object references with a placeholder" do
    person = RecursivePersonForAwesomePrint.new("Diana")
    person.friend = person

    output = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false).awesome(person)

    output.should contain("@name = \"Diana\"")
    output.should contain("@friend = ...RecursivePersonForAwesomePrint...")
  end
end
