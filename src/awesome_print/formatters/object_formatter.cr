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
        data = field_lines
        if should_be_limited? && data.size > get_limit_size
          data = limited(data, field_width, true)
          separator_index = get_limit_size // 2
          data[separator_index] = "#{indent(inspector.indent_size)}#{data[separator_index]}"
        end

        "#{object_prefix} #{colorize("{", :array)}\n#{data.join(",\n")}\n#{indent}#{colorize("}", :array)}#{object_suffix}"
      end

      private def single_line_object : String
        "#{object_prefix} #{colorize("{", :array)} #{limited_inline_values(single_line_field_lines).join(", ")} #{colorize("}", :array)}#{object_suffix}"
      end

      private def field_lines : Array(String)
        field_entries.map do |_recursive, colored_key, rendered_value|
          indented do
            "#{align(colored_key, field_width)}#{colorize(" = ", :hash)}#{rendered_value}"
          end
        end
      end

      private def single_line_field_lines : Array(String)
        field_entries.map do |_recursive, colored_key, rendered_value|
          "#{colored_key}#{colorize(" = ", :hash)}#{rendered_value}"
        end
      end

      private def field_width : Int32
        field_entries.max_of { |entry| field_name(entry[1]).size } + inspector.indent_size.abs
      end

      private def field_entries : Array({Bool, String, String})
        entries = [] of {Bool, String, String}

        {% for ivar in T.instance_vars %}
          key = colorize("@{{ ivar.id }}", :variable)
          value = @object.@{{ ivar.id }}
          entries << {inspector.recursive_reference?(value), key, inspector.awesome(value)}
        {% end %}

        if inspector.order.sorted?
          entries.sort_by do |entry|
            recursive, colored_key, _rendered_value = entry
            {recursive ? 1 : 0, field_name(colored_key)}
          end
        else
          entries.sort_by do |entry|
            recursive, _colored_key, _rendered_value = entry
            recursive ? 1 : 0
          end
        end
      end

      private def field_name(colored_key : String) : String
        colorless(colored_key)
      end

      private def object_prefix : String
        {% if T < Reference %}
          String.build do |io|
            io << colorize("#<", :hash)
            io << colorize({{ T.name.stringify }}, :class)
            if inspector.object_id
              io << colorize(":0x", :hash)
              io << colorize(object.object_id.to_s(16), :number)
            end
          end
        {% else %}
          colorize({{ T.name.stringify }}, :class)
        {% end %}
      end

      private def object_suffix : String
        {% if T < Reference %}
          colorize(">", :hash)
        {% else %}
          ""
        {% end %}
      end
    end
  end
end
