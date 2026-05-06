require "./spec_helper"

private def strip_ansi(value : String) : String
  value.gsub(/\e\[[\d;]+m/, "")
end

private def raised_exception(message = "bad value") : Exception
  raise ArgumentError.new(message)
rescue ex
  ex
end

class AwesomePrint::Formatters::ExceptionFormatter
  def format_frame_for_test(frame : String) : String
    format_frame(frame)
  end

  def limited_backtrace_for_test(backtrace : Array(String)) : Array(String)
    limited_backtrace(backtrace)
  end
end

describe AwesomePrint::Formatters::ExceptionFormatter do
  it "formats exceptions with class and message" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false)
    output = AwesomePrint::Formatters::ExceptionFormatter.new(ArgumentError.new("bad value"), inspector).format

    output.should eq(%(ArgumentError("bad value")))
  end

  it "includes cause when present" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false)
    cause = RuntimeError.new("root cause")
    error = Exception.new("bad value", cause)
    output = AwesomePrint::Formatters::ExceptionFormatter.new(error, inspector).format

    output.should eq(%(Exception("bad value")
  caused by:
    RuntimeError("root cause")))
  end

  it "prints backtrace by default when present" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false)
    output = AwesomePrint::Formatters::ExceptionFormatter.new(raised_exception, inspector).format

    output.should contain(%(ArgumentError("bad value")))
    output.should contain("\n  from ")
    output.should contain("spec/exception_formatter_spec.cr")
  end

  it "limits backtrace frames by default" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false, backtrace_limit: 1)
    output = AwesomePrint::Formatters::ExceptionFormatter.new(raised_exception, inspector).format

    output.should contain("\n  from ")
    output.should contain("... ")
    output.should contain("more frames")
  end

  it "allows backtrace output to be disabled" do
    inspector = AwesomePrint::Inspector.new(colors_enabled: false, show_backtrace: false)
    output = AwesomePrint::Formatters::ExceptionFormatter.new(raised_exception, inspector).format

    output.should eq(%(ArgumentError("bad value")))
  end

  it "keeps exception text stable when colors are enabled" do
    inspector = AwesomePrint::Inspector.new(show_backtrace: false)
    output = AwesomePrint::Formatters::ExceptionFormatter.new(ArgumentError.new("bad value"), inspector).format

    strip_ansi(output).should eq(%(ArgumentError("bad value")))
  end

  it "distinguishes project and runtime frames" do
    inspector = AwesomePrint::Inspector.new
    formatter = AwesomePrint::Formatters::ExceptionFormatter.new(ArgumentError.new("bad value"), inspector)

    project_frame = "#{Dir.current}/spec/exception_formatter_spec.cr:1:1 in 'demo'"
    runtime_frame = "/home/zw963/Crystal/share/crystal/src/spec/example.cr:50:13 in 'internal_run'"

    strip_ansi(formatter.format_frame_for_test(project_frame)).should eq("spec/exception_formatter_spec.cr:1:1 in 'demo'")
    strip_ansi(formatter.format_frame_for_test(runtime_frame)).should eq(runtime_frame)
    formatter.format_frame_for_test(project_frame).should_not eq(formatter.format_frame_for_test(runtime_frame))
  end

  it "colors project frame path and location separately" do
    inspector = AwesomePrint::Inspector.new
    formatter = AwesomePrint::Formatters::ExceptionFormatter.new(ArgumentError.new("bad value"), inspector)
    project_frame = "#{Dir.current}/spec/exception_formatter_spec.cr:12:34 in 'demo'"
    colored = formatter.format_frame_for_test(project_frame)

    strip_ansi(colored).should eq("spec/exception_formatter_spec.cr:12:34 in 'demo'")
    colored.should contain(AwesomePrint::Colors.string("spec/exception_formatter_spec.cr"))
    colored.should contain(AwesomePrint::Colors.number(":12:34"))
    colored.should contain(AwesomePrint::Colors.hash(" in 'demo'"))
  end

  it "deemphasizes /usr/lib and .cache frames instead of hiding them" do
    inspector = AwesomePrint::Inspector.new
    formatter = AwesomePrint::Formatters::ExceptionFormatter.new(ArgumentError.new("bad value"), inspector)
    usr_lib_frame = "/usr/lib/libc.so.6 in '__libc_start_main'"
    cache_frame = "/home/zw963/.cache/crystal/foo.cr:1:1 in 'cached'"
    unknown_frame = "??? in ???"

    strip_ansi(formatter.format_frame_for_test(usr_lib_frame)).should eq(usr_lib_frame)
    strip_ansi(formatter.format_frame_for_test(cache_frame)).should eq(cache_frame)
    strip_ansi(formatter.format_frame_for_test(unknown_frame)).should eq(unknown_frame)
    formatter.format_frame_for_test(usr_lib_frame).should eq(AwesomePrint::Colors.grayish(usr_lib_frame))
    formatter.format_frame_for_test(cache_frame).should eq(AwesomePrint::Colors.grayish(cache_frame))
    formatter.format_frame_for_test(unknown_frame).should eq(AwesomePrint::Colors.grayish(unknown_frame))
  end
end
