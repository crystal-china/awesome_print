module AwesomePrint
  module Formatters
    class ObjectFormatter(T) < BaseFormatter
      getter object : T

      def initialize(@object : T, inspector : Inspector)
        super(inspector)
      end

      def format : String
        {% if T.instance_vars.empty? %}
          object.pretty_inspect(indent: inspector.indent_size).to_s
        {% else %}
          if inspector.multiline
            multiline_object
          else
            single_line_object
          end
        {% end %}
      end

      private def multiline_object : String
        "#{object_prefix} {\n#{field_lines.join(",\n")}\n#{indent}}#{object_suffix}"
      end

      private def single_line_object : String
        "#{object_prefix} { #{single_line_field_lines.join(", ")} }#{object_suffix}"
      end

      private def field_lines : Array(String)
        lines = [] of String

        {% for ivar in T.instance_vars %}
          lines << indented do
            key = colorize("@{{ ivar.id }}", :variable)
            "#{align(key, field_width)}#{colorize(" = ", :hash)}#{inspector.awesome(@object.@{{ ivar.id }})}"
          end
        {% end %}

        lines
      end

      private def single_line_field_lines : Array(String)
        lines = [] of String

        {% for ivar in T.instance_vars %}
          key = colorize("@{{ ivar.id }}", :variable)
          lines << "#{key}#{colorize(" = ", :hash)}#{inspector.awesome(@object.@{{ ivar.id }})}"
        {% end %}

        lines
      end

      private def field_width : Int32
        max_width = 0

        {% for ivar in T.instance_vars %}
          ivar_width = {{ ivar.name.stringify.size + 1 }}
          max_width = ivar_width if ivar_width > max_width
        {% end %}

        max_width + inspector.indent_size.abs
      end

      private def object_prefix : String
        {% if T < Reference %}
          String.build do |io|
            io << "#<" << {{ T.name.stringify }} << ":0x"
            object.object_id.to_s(io, 16)
          end
        {% else %}
          {{ T.name.stringify }}
        {% end %}
      end

      private def object_suffix : String
        {% if T < Reference %}
          ">"
        {% else %}
          ""
        {% end %}
      end
    end
  end
end
