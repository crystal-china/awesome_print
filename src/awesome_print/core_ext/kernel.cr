module AwesomePrint
  module KernelExtension
    macro ap!(*args, file = __FILE__, line = __LINE__)
      {% unless args.empty? %}
        %arg_values = {
          {% for arg in args %}
            {{ arg }},
          {% end %}
        }

        %arg_expressions = {
          {% for arg in args %}
            {{ arg.stringify }},
          {% end %}
        }

        {% for arg, i in args %}
          ::AwesomePrint.print(
            expression: %arg_expressions[{{ i }}],
            value: %arg_values[{{ i }}],
            file: {{ file }},
            line: {{ line }}
          )
        {% end %}

        {% if args.size == 1 %}
          %arg_values.first
        {% else %}
          %arg_values
        {% end %}
      {% end %}
    end
  end
end

include AwesomePrint::KernelExtension
