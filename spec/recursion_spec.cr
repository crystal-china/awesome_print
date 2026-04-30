require "./spec_helper"

private class RecursivePersonForAwesomePrint
  property friend : RecursivePersonForAwesomePrint?

  def initialize(@name : String)
  end
end

private alias RecursiveArrayValueForAwesomePrint = String | Array(RecursiveArrayValueForAwesomePrint)

describe AwesomePrint::Inspector do
  it "replaces recursive object references with a placeholder" do
    person = RecursivePersonForAwesomePrint.new("Diana")
    person.friend = person

    output = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false).awesome(person)

    output.should contain("@name = \"Diana\"")
    output.should contain("@friend = ...RecursivePersonForAwesomePrint...")
  end

  it "puts non-recursive fields before recursive fields" do
    person = RecursivePersonForAwesomePrint.new("Diana")
    person.friend = person

    output = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false).awesome(person)

    output.index("@name = \"Diana\"").not_nil!.should be < output.index("@friend = ...RecursivePersonForAwesomePrint...").not_nil!
  end

  it "keeps recursive fields after non-recursive fields when order is sorted" do
    person = RecursivePersonForAwesomePrint.new("Diana")
    person.friend = person

    output = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false, order: :sorted).awesome(person)

    output.index("@name = \"Diana\"").not_nil!.should be < output.index("@friend = ...RecursivePersonForAwesomePrint...").not_nil!
  end

  it "keeps recursive fields visible when limit is applied" do
    person = RecursivePersonForAwesomePrint.new("Diana")
    person.friend = person

    output = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false, limit: 1).awesome(person)

    output.should contain("@friend = ...RecursivePersonForAwesomePrint...")
  end

  it "replaces recursive arrays with an array placeholder" do
    values = [] of RecursiveArrayValueForAwesomePrint
    values << "one"
    values << values

    output = AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false).awesome(values)

    output.should contain("[0] \"one\"")
    output.should contain("[1] [...]")
  end
end
