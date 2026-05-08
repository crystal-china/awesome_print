module AwesomePrint
  module Formatters
    class StructFormatter(T) < BaseFormatter
      getter struct : T

      def initialize(@struct : T, inspector : Inspector)
        super(inspector)
      end

      def format : String
        {% if T.instance_vars.empty? %}
          @struct.pretty_inspect(indent: inspector.indent_size).to_s
        {% else %}
          if !inspector.raw && prefer_inspect_representation?
            @struct.inspect
          elsif inspector.multiline
            multiline_struct
          else
            single_line_struct
          end
        {% end %}
      end

      private def prefer_inspect_representation? : Bool
        inspected = @struct.inspect
        !inspected.starts_with?({{ T.name.stringify + "(" }})
      end

      private def multiline_struct : String
        data = field_lines
        if should_be_limited?
          data = limited(data, field_width, true)
          separator_index = get_limit_size // 2
          data[separator_index] = "#{indent(inspector.indent_size)}#{data[separator_index]}"
        end

        "#{struct_prefix} #{colorize("{", :array)}\n#{data.join(",\n")}\n#{indent}#{colorize("}", :array)}"
      end

      private def single_line_struct : String
        "#{struct_prefix} #{colorize("{", :array)} #{single_line_field_lines.join(", ")} #{colorize("}", :array)}"
      end

      private def field_lines : Array(String)
        field_entries.map do |colored_key, rendered_value|
          indented do
            "#{align(colored_key, field_width)}#{colorize(" = ", :hash)}#{rendered_value}"
          end
        end
      end

      private def single_line_field_lines : Array(String)
        field_entries.map do |colored_key, rendered_value|
          "#{colored_key}#{colorize(" = ", :hash)}#{rendered_value}"
        end
      end

      private def field_width : Int32
        field_entries.max_of { |entry| colorless(entry[0]).size } + inspector.indent_size.abs
      end

      private def field_entries : Array({String, String})
        entries = [] of {String, String}

        {% for ivar in T.instance_vars %}
          key = colorize("@{{ ivar.id }}", :variable)
          value = @struct.@{{ ivar.id }}
          entries << {key, inspector.awesome(value)}
        {% end %}

        if inspector.order.sorted?
          entries.sort_by { |entry| colorless(entry[0]) }
        else
          entries
        end
      end

      private def struct_prefix : String
        colorize({{ T.name.stringify }}, :class)
      end
    end
  end
end
