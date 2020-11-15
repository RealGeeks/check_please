def strip_trailing_whitespace(s)
  s.lines.map(&:rstrip).join("\n")
end

def fixture_file_name(basename)
  "spec/fixtures/#{basename}"
end

def fixture_file_contents(basename)
  File.read(fixture_file_name(basename))
end
