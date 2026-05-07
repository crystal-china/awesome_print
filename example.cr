require "./src/awesome_print"

class Person
  def initialize(@name : String, @rank : Int32, @admin : Bool, @very_long_status : String)
  end
end

class RecursivePerson
  property friend : RecursivePerson?

  def initialize(@name : String)
  end
end

class ManyFields
  def initialize(
    @a : Int32,
    @b : Int32,
    @c : Int32,
    @d : Int32,
    @e : Int32,
    @f : Int32,
    @g : Int32
  )
  end
end

class MixedKey
  def initialize(@id : Int32)
  end
end

def root_failure
  raise RuntimeError.new("root cause")
end

def wrapped_failure
  root_failure
rescue ex
  raise Exception.new("bad value", ex)
end

struct StructKey
  def initialize(@x : Int32, @y : Int32)
  end
end

enum DemoEnum
  Alpha
  Beta
end

numbers = [1, 2, 3]
long_numbers = [1, 2, 3, 4, 5, 6, 7]
huge_numbers = (1..1500000).to_a
nested_numbers = [1, [2, 3], 4]
bytes_value = Bytes[65, 66, 67]
slice_value = Slice[1, 2, 3]
static_array_value = StaticArray[1, 2, 3]
enum_value = DemoEnum::Alpha
path_value = Path["foo/bar"]
regex_value = /foo/i
range_values = 1..5
time_value = Time.utc(2026, 5, 6, 12, 34, 56)
set_values = Set{1, 2, 3}
tuple_values = {1, 2, 3}
literal_values = [:alpha, nil, true, false]
error_value = begin
  wrapped_failure
rescue ex
  ex
end
profile = {"name" => "Diana", "rank" => 1, "admin" => false}
format_profile = {"id" => 1, "display_name" => "Diana", "very_long_profile_key" => true}
mixed_key_profile = {1 => "one", true => "yes", MixedKey.new(7) => "object"}
composite_key_profile = {
  {1, 2} => "tuple",
  ({name: "Diana", rank: 1}) => "named",
  StructKey.new(3, 4) => "struct",
}
user = {
  name: "Diana",
  rank: 1,
  admin: false,
}
format_user = {
  id: 1,
  display_name: "Diana",
  very_long_profile_key: true,
}
person = Person.new("Diana", 1, false, "active")
recursive_person = RecursivePerson.new("Diana")
recursive_person.friend = recursive_person
many_fields = ManyFields.new(1, 2, 3, 4, 5, 6, 7)

puts "-- collections --"
ap!(numbers)
ap!(long_numbers, limit: 5)
ap!(huge_numbers, limit: 7)
ap!(nested_numbers)
ap!(set_values)
ap!(tuple_values)
ap!(profile)
ap!(user)

puts
puts "-- hash formats --"
ap!(format_profile)
ap!(format_profile, hash_format: :rocket)
ap!(format_profile, hash_format: :json)
ap!(format_user)
ap!(format_user, hash_format: :rocket)
ap!(format_user, hash_format: :json)

puts
puts "-- collection variants --"
ap!(bytes_value)
ap!(slice_value)
ap!(static_array_value)
ap!(mixed_key_profile)
ap!(composite_key_profile)

puts
puts "-- objects --"
ap!(StructKey.new(3, 4))
ap!(person)
ap!(recursive_person)
ap!(many_fields, limit: 5)
ap!(person, order: :sorted)

puts
puts "-- single line --"
ap!(numbers, multiline: false)
ap!(profile, multiline: false, limit: 5, order: :sorted)
ap!(person, multiline: false, order: :sorted, limit: 3)

puts
puts "-- scalar and special values --"
ap!(literal_values)
ap!(enum_value)
ap!(path_value)
ap!(regex_value)
ap!(range_values)
ap!(time_value)
ap!(numbers.size + user[:rank])

File.tempfile("awesome-print-demo") do |file|
  ap!(file)
end

dir_value = Dir.new(".")
ap!(dir_value)
dir_value.close

puts
puts "-- exception --"
ap!(error_value)

puts
# Keep one no-color baseline sample for structure-only comparisons.
puts "-- custom inspector: natural order --"
puts AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false, order: :natural).awesome(profile)

puts
# Keep one no-color baseline sample for structure-only comparisons.
puts "-- custom inspector: sorted order --"
puts AwesomePrint::Inspector.new(indent_size: 2, colors_enabled: false, order: :sorted).awesome(person)
