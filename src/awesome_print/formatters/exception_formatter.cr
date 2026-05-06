module AwesomePrint
  module Formatters
    class ExceptionFormatter < BaseFormatter
      getter exception : Exception

      def initialize(@exception : Exception, inspector : Inspector)
        super(inspector)
      end

      def format : String
        format_exception(exception)
      end

      private def format_exception(error : Exception, depth : Int32 = 0) : String
        String.build do |io|
          io << exception_header(error)

          if inspector.show_backtrace
            frames = limited_backtrace(error.backtrace?)
            frames.each do |frame|
              io << '\n'
              io << nested_indent(depth + 1)
              io << colorize("from ", :hash)
              io << format_frame(frame)
            end
          end

          if cause = error.cause
            io << '\n'
            io << nested_indent(depth + 1)
            io << colorize("caused by:", :hash)
            io << '\n'
            io << indent_block(format_exception(cause, depth + 1), depth + 2)
          end
        end
      end

      private def exception_header(error : Exception) : String
        String.build do |io|
          io << colorize(error.class.to_s, :class)
          io << colorize("(", :array)
          io << Colors.string(error.message.inspect, inspector.colorize?)
          io << colorize(")", :array)
        end
      end

      private def limited_backtrace(backtrace : Array(String)?) : Array(String)
        return [] of String unless backtrace

        frames = backtrace
        limit = inspector.backtrace_limit
        return frames if limit <= 0 || frames.size <= limit

        visible = frames.first(limit)
        visible + ["... #{frames.size - limit} more frames"]
      end

      private def format_frame(frame : String) : String
        if frame.starts_with?("... ")
          colorize(frame, :hash)
        else
          normalized = relative_frame(frame)
          if in_project_frame?(frame)
            colorize(normalized, :string)
          elsif deemphasized_frame?(frame)
            colorize(normalized, :grayish)
          elsif in_runtime_frame?(frame)
            colorize(normalized, :grayish)
          else
            colorize(normalized, :pale)
          end
        end
      end

      private def in_project_frame?(frame : String) : Bool
        root = "#{Dir.current}/"
        frame.includes?(root) || frame.starts_with?(Dir.current)
      end

      private def in_runtime_frame?(frame : String) : Bool
        frame.includes?("/share/crystal/src/") || frame.includes?("/lib/crystal/")
      end

      private def deemphasized_frame?(frame : String) : Bool
        frame.includes?("/usr/lib") || frame.includes?(".cache") || frame.includes?("???")
      end

      private def relative_frame(frame : String) : String
        root = "#{Dir.current}/"
        frame.gsub(root, "")
      end

      private def nested_indent(depth : Int32) : String
        " " * (depth * 2)
      end

      private def indent_block(text : String, depth : Int32) : String
        prefix = nested_indent(depth)
        text.lines.join("\n") { |line| "#{prefix}#{line}" }
      end
    end
  end
end
