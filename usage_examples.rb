require 'check_please'

reference = { foo: "wibble" }
candidate = { bar: "wibble" }

puts CheckPlease.render_diff(reference, candidate)

# this should print the following to stdout:
_ = <<EOF
  TYPE    | PATH | REFERENCE | CANDIDATE
  --------|------|-----------|----------
  missing | /foo | wibble    |
  extra   | /bar |           | wibble
EOF
