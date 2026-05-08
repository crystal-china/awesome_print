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
            colorize_inspect_representation(@struct.inspect)
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

      private def colorize_inspect_representation(inspected : String) : String
        return inspected unless inspector.colorize?
        return inspected unless inspected.starts_with?("def ")

        colorize_method_signature(inspected)
      end

      private def colorize_method_signature(signature : String) : String
        String.build do |io|
          io << colorize("def", :keyword)
          io << ' '

          index = 4
          while index < signature.size && signature[index] != '('
            index += 1
          end

          io << colorize(signature[4, index - 4], :symbol)

          colon_context = false
          while index < signature.size
            char = signature[index]

            if char == '"'
              closing = index + 1
              escaped = false
              while closing < signature.size
                current = signature[closing]
                if current == '"' && !escaped
                  break
                end
                escaped = current == '\\' && !escaped
                escaped = false unless current == '\\'
                closing += 1
              end
              io << colorize(signature[index..closing], :string)
              index = closing + 1
            elsif char.in?('(', ')', ',', ':')
              io << colorize(char.to_s, :hash)
              colon_context = char == ':'
              index += 1
            elsif colon_context && (char.alphanumeric? || char.in?('_', ':', '.', '?'))
              start = index
              while index < signature.size && (signature[index].alphanumeric? || signature[index].in?('_', ':', '.', '?'))
                index += 1
              end
              io << colorize(signature[start, index - start], :class)
              colon_context = false
            else
              io << char
              colon_context = false unless char.whitespace?
              index += 1
            end
          end
        end
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
