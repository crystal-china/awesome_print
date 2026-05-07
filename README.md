# awesome_print

`awesome_print` is a Crystal pretty-printer with an `ap!` macro for debugging.

It borrows the overall feel and color scheme from Ruby `awesome_print`, keeps a formatter-oriented core closer to `amazing_print`, and uses a Crystal-friendly macro entrypoint similar to `debug.cr`.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     awesome_print:
       github: zw963/awesome_print
       version: ~> 0.1.0
   ```

2. Run `shards install`

## Usage

```crystal
require "awesome_print"

user = {
  name: "Diana",
  rank: 1,
  admin: false,
}

ap!(user)
```

`ap!` prints:

- file and line
- the original expression
- the formatted value
- the Crystal type

and then returns the original value, so it can stay inside expressions.

By default, `ap!`, `AwesomePrint.format(...)`, and `AwesomePrint::Inspector.new` all use `indent_size: 4`.

When given multiple expressions, `ap!` prints each one and returns them as a tuple.

If you want the formatted text without printing, use:

```crystal
text = AwesomePrint.format(user)
```

`AwesomePrint.format(...)` returns plain text by default.
Pass `colors_enabled: true` if you want ANSI colors in the returned string.
`ap!` still prints with colors by default.

### Options

`ap!` forwards named arguments into `AwesomePrint::Inspector.new(...)`.

Currently supported options:

- `indent_size : Int32 = 4`
- `multiline : Bool = true`
- `index : Bool = true`
- `limit : Int32? = nil`
- `raw : Bool = false`
- `colors_enabled : Bool = true`
- `show_backtrace : Bool = true`
- `backtrace_limit : Int32 = 8`
- `order : AwesomePrint::Inspector::Order = :natural`
- `hash_format : AwesomePrint::Inspector::HashFormat = :symbol`

These are also the defaults used by `ap!` and `AwesomePrint.format(...)`, unless you override them explicitly.

### Examples

Single line output:

```crystal
ap!([1, 2, 3], multiline: false)
```

Limited output:

```crystal
ap!([1, 2, 3, 4, 5, 6, 7], limit: 5)
```

Hash output styles:

```crystal
ap!(user_hash, hash_format: :symbol)
ap!(user_hash, hash_format: :rocket)
ap!(user_hash, hash_format: :json)
```

Sorted object fields:

```crystal
person = Person.new("Diana", 1, false, "active")
ap!(person, order: :sorted)
```

Raw object output:

```crystal
ap!(user_view, raw: true)
```

Backtrace control:

```crystal
ap!(error)
ap!(error, show_backtrace: false)
ap!(error, backtrace_limit: 5)
```

Multiple expressions:

```crystal
value1, value2 = ap!(user.id, user.name)
```

String output without printing:

```crystal
text = AwesomePrint.format(user, multiline: false)
colored = AwesomePrint.format(user, multiline: false, colors_enabled: true)
```

Hash-like objects with `to_h`:

```crystal
class UserView
  def initialize(@name : String, @rank : Int32)
  end

  def to_h
    {name: @name, rank: @rank}
  end
end

AwesomePrint.format(UserView.new("Diana", 1))
# => formats as a mapping by default

AwesomePrint.format(UserView.new("Diana", 1), raw: true)
# => formats as an object with instance variables
```

### Supported formatters

Current custom formatters cover:

- `Array`
- `Bytes`
- `Class`
- `Slice`
- `StaticArray`
- `Set`
- `Tuple`
- `Hash`
- `NamedTuple`
- `Struct`
- regular objects
- `Enum`
- `Exception`
- `Path`
- `File`
- `Dir`
- `Regex`
- `Range`
- `Time`

Notes:

- `Hash` and `NamedTuple` support `hash_format: :symbol | :rocket | :json`
- objects that respond to `to_h` and return `Hash` or `NamedTuple` are formatted as mappings by default
- `raw: true` forces those objects back onto the normal object formatter path

### Preview script

For a quick manual preview of the current output:

```bash
crystal run example.cr
```

## Development

Run the full spec suite:

```bash
CRYSTAL_CACHE_DIR=/tmp/crystal-cache crystal spec
```

The repository also includes:

- `example.cr` for manual output review
- `2.cr` for a very small color comparison sample

## Contributing

1. Fork it (<https://github.com/zw963/awesome_print/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Billy.Zheng](https://github.com/zw963) - creator and maintainer
