def strip_trailing_whitespace(s)
  s.lines.map(&:rstrip).join("\n")
end
