# awesome_print

Colorful pretty printing for Crystal.

`awesome_print` provides an `ap!` debug macro and a string formatter. It is inspired by Ruby [`awesome_print`](https://github.com/awesome-print/awesome_print) and [`amazing_print`](https://github.com/amazing-print/amazing_print), but implemented in a Crystal-friendly style.

## Installation

```yaml
dependencies:
  awesome_print:
    github: zw963/awesome_print
    version: ~> 0.1.0
```

Then run:

```bash
shards install
```

## Usage

```crystal
require "awesome_print"

user = {name: "Diana", rank: 1, admin: false}

ap! user
```

`ap!` prints the source location, expression, formatted value, and type. It returns the original
value, so it can stay inside debugging expressions.

```crystal
value = ap!(user) # => returns user
```

Multiple expressions are printed one by one and returned as a tuple:

```crystal
id, name = ap!(user[:id], user[:name])
```

To format without printing:

```crystal
text = AwesomePrint.format(user)
```

`AwesomePrint.format(...)` returns plain text by default. Use `colors_enabled: true` for ANSI
colors. `ap!` prints with colors by default.

## Options

Options are passed to `AwesomePrint::Inspector`:

```crystal
ap!(user, limit: 5, order: :sorted)
AwesomePrint.format(user, multiline: false)
```

Common options:

- `indent_size: 4`
- `multiline: true`
- `index: true`
- `limit: nil`
- `order: :natural | :sorted`
- `hash_format: :symbol | :rocket | :json`
- `raw: false`
- `colors_enabled: true`
- `show_backtrace: true`
- `backtrace_limit: 8`

## Examples

```crystal
ap!([1, 2, 3], multiline: false)
ap!([1, 2, 3, 4, 5, 6, 7], limit: 5)
ap!(hash, hash_format: :rocket)
ap!(object, raw: true)
ap!(error, backtrace_limit: 5)
```

Objects that implement `to_h` and return a `Hash` or `NamedTuple` are formatted as mappings by
default. Use `raw: true` to inspect their instance variables instead.

## Supported Types

Custom formatters currently cover:

`Array`, `Hash`, `NamedTuple`, `Tuple`, `Set`, `Slice`, `Bytes`, `StaticArray`, `Struct`,
regular objects, `Class`, `Enum`, `Exception`, `Path`, `File`, `Dir`, `Regex`, `Range`, and `Time`.

## Preview

Run:

```bash
crystal run example.cr
```

`example.cr` shows the current output style across common Crystal values.

## Development

```bash
CRYSTAL_CACHE_DIR=/tmp/crystal-cache crystal spec
```

## Contributors

- [Billy.Zheng](https://github.com/zw963)
