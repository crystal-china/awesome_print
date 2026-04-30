module AwesomePrint
  module KernelExtension
    macro ap!(*args, file = __FILE__, line = __LINE__, **options)
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

        {% unless options.empty? %}
          %ap_inspector = ::AwesomePrint::Inspector.new(
            indent_size: 2,
            {{ options.double_splat }}
          )
        {% else %}
          %ap_inspector = ::AwesomePrint::Inspector.new(indent_size: 2)
        {% end %}

        {% for arg, i in args %}
          ::AwesomePrint.print(
            expression: %arg_expressions[{{ i }}],
            value: %arg_values[{{ i }}],
            file: {{ file }},
            line: {{ line }},
            inspector: %ap_inspector
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
