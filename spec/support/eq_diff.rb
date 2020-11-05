module EqDiff
  def eq_diff(type, path, ref:, can:)
    expected = ExpectedDiff.new(type, path, ref, can)
    Matcher.new(expected)
  end

  ExpectedDiff = Struct.new(:type, :path, :reference, :candidate) do
    def ==(actual)
      type == actual.type \
        && path == actual.path \
        && reference == actual.reference \
        && candidate == actual.candidate
    end
  end

  class Matcher
    def initialize(expected)
      @expected = expected
    end

    def matches?(actual)
      @actual = actual
      @expected == @actual
    end

    def failure_message
      mismatches = []
      %i[ type path reference candidate ].each do |attr_name|
        exp = @expected.send(attr_name)
        act = @actual.send(attr_name)
        next if exp == act
        mismatches << "- expected #{attr_name} to be #{exp.inspect} but got #{act.inspect}"
      end

      "Diff comparison failed!\n#{mismatches.join("\n")}"
    end
  end
end

RSpec::configure do |config|
  config.include EqDiff
end
