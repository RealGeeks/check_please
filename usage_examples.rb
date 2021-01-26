require 'check_please'

reference = { "foo" => "wibble" }
candidate = { "bar" => "wibble" }



##### Printing diffs #####

puts CheckPlease.render_diff(reference, candidate)

# this should print the following to stdout:
_ = <<EOF
  TYPE    | PATH | REFERENCE | CANDIDATE
  --------|------|-----------|----------
  missing | /foo | wibble    |
  extra   | /bar |           | wibble
EOF



##### Doing your own thing with diffs #####

diffs = CheckPlease.diff(reference, candidate)

# `diffs` is a custom collection (type: CheckPlease::Diffs) that contains
# individual Diff objects for you to inspect as you see fit.
#
# If you come up with a useful way to present these, feel free to submit a PR
# with a new class in `lib/check_please/printers` !

# To print these in the console, you can just do:
puts diffs

# If for some reason you want to print the JSON version, it gets a little more verbose:
puts diffs.to_s(format: :json)
