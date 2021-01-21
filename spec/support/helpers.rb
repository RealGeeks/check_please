def strip_trailing_whitespace(s)
  s.lines.map(&:rstrip).join("\n")
end

def fixture_file_name(basename)
  "spec/fixtures/#{basename}"
end

def fixture_file_contents(basename)
  File.read(fixture_file_name(basename))
end

def _compare(expected, actual)
  case actual
  when true, false, nil
    expect( actual ).to be( expected ) # identity
  else
    expect( actual ).to eq( expected ) # equality
  end
end

# NOTE: "basic" only means there are no arguments to the method :)
def has_these_basic_properties(messages_and_expected_returns = {})
  messages_and_expected_returns.each do |message, expected|
    specify "##{message} returns #{expected.inspect}" do
      actual = subject.send(message)
      _compare expected, actual
    end
  end
end

def pathify(name)
  CheckPlease::Path.new(name)
end

def flagify(attrs = {})
  CheckPlease::Flags.new(attrs)
end
