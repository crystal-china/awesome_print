require "./spec_helper"

private class ConfigPersonForAwesomePrint
  def initialize(@name : String, @rank : Int32)
  end
end

private def reset_awesome_print_settings
  AwesomePrint.configure do |settings|
    settings.indent_size = 4
    settings.multiline = true
    settings.index = true
    settings.limit = nil
    settings.raw = false
    settings.colors_enabled = nil
    settings.show_backtrace = true
    settings.backtrace_limit = 8
    settings.object_id = true
    settings.order = :natural
    settings.hash_format = :symbol
  end
end

private def strip_ansi(value : String) : String
  value.gsub(/\e\[[\d;]+m/, "")
end

describe "AwesomePrint.configure" do
  it "applies configured defaults to ap!" do
    reset_awesome_print_settings

    begin
      AwesomePrint.configure do |settings|
        settings.limit = 5
        settings.object_id = false
      end

      io = IO::Memory.new
      AwesomePrint.output = io
      person = ConfigPersonForAwesomePrint.new("Diana", 1)

      ap!([1, 2, 3, 4, 5, 6, 7])
      ap!(person)

      output = strip_ansi(io.to_s)
      output.should contain("[2] .. [4]")
      output.should contain("#<ConfigPersonForAwesomePrint {")
      output.should_not contain(":0x")
    ensure
      reset_awesome_print_settings
    end
  end

  it "lets per-call options override configured defaults" do
    reset_awesome_print_settings

    begin
      AwesomePrint.configure do |settings|
        settings.multiline = false
        settings.order = :sorted
      end

      output = AwesomePrint.format({"z" => 1, "a" => 2}, multiline: true, order: :natural)

      output.should eq <<-TEXT
{
    "z" => 1,
    "a" => 2
}
TEXT
    ensure
      reset_awesome_print_settings
    end
  end

  it "allows configured colors while still accepting an explicit plain format call" do
    reset_awesome_print_settings

    begin
      AwesomePrint.configure do |settings|
        settings.colors_enabled = true
      end

      colored = AwesomePrint.format([1, 2, 3], multiline: false)
      plain = AwesomePrint.format([1, 2, 3], multiline: false, colors_enabled: false)

      colored.should_not eq("[ 1, 2, 3 ]")
      strip_ansi(colored).should eq("[ 1, 2, 3 ]")
      plain.should eq("[ 1, 2, 3 ]")
    ensure
      reset_awesome_print_settings
    end
  end
end
