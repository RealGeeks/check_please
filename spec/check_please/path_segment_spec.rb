RSpec.describe CheckPlease::PathSegment do
  def self.match_eh_returns(values_and_expected_returns = {})
    values_and_expected_returns.each do |value, expected|
      specify "#match?(#{value.inspect}) returns #{expected.inspect}" do
        actual = subject.match?(value)
        _compare expected, actual
      end
    end
  end

  describe ".new" do
    it "returns the instance when given an instance of itself" do
      foo = described_class.new("foo")
      returned = described_class.new(foo)
      expect( returned ).to be( foo ) # object identity check
    end

    it "raises CheckPlease::PathSegment::IllegalName when given a string containing a space between non-space characters " do
      expect { described_class.new("hey bob") }.to \
        raise_error( CheckPlease::PathSegment::IllegalName )
    end

    it "returns an empty instance with name='' when given no arguments" do
      seg = described_class.new()
      expect( seg      ).to be_a(described_class)
      expect( seg.name ).to eq( "" )
      expect( seg      ).to be_empty
    end

    it "returns an instance with name='foo' when given 'foo' (a string)" do
      seg = described_class.new("foo")
      expect( seg      ).to     be_a(described_class)
      expect( seg.name ).to     eq( "foo" )
      expect( seg      ).to_not be_empty
    end

    it "returns an instance with name='foo' when given '   foo ' (a string with leading/trailing whitespace)" do
      seg = described_class.new("   foo ")
      expect( seg      ).to be_a(described_class)
      expect( seg.name ).to eq( "foo" )
      expect( seg      ).to_not be_empty
    end

    it "returns an instance with name='foo' when given :foo (a symbol)" do
      seg = described_class.new(:foo)
      expect( seg      ).to     be_a(described_class)
      expect( seg.name ).to     eq( "foo" )
      expect( seg      ).to_not be_empty
    end

    it "returns an instance with name='42' when given 42 (an integer)" do
      seg = described_class.new(42)
      expect( seg      ).to     be_a(described_class)
      expect( seg.name ).to     eq( "42" )
      expect( seg      ).to_not be_empty
    end
  end

  describe "created with no arguments" do
    subject { described_class.new() }

    has_these_basic_properties(
      :empty?    => true,
      :name      => "",
      :key       => nil,
      :key_value => nil,
    )

    match_eh_returns(
      ""       => true, # names match
      "foo"    => false,
      "bar"    => false,
      ":foo"   => false,
      "foo=23" => false,
      "foo=42" => false,
    )
  end

  describe "created with 'foo'" do
    subject { described_class.new('foo') }

    has_these_basic_properties(
      :empty?    => false,
      :name      => "foo",
      :key       => nil,
      :key_value => nil,
    )

    match_eh_returns(
      ""       => false,
      "foo"    => true, # names match
      "bar"    => false,
      ":foo"   => false,
      "foo=23" => false,
      "foo=42" => false,
    )
  end

  describe "created with ':foo'" do
    subject { described_class.new(':foo') }

    has_these_basic_properties(
      :empty?    => false,
      :name      => ":foo",
      :key       => "foo",
      :key_value => nil,
    )

    match_eh_returns(
      ""       => false,
      "foo"    => false,
      "bar"    => false,
      ":foo"   => false,
      "foo=23" => true, # segment is a key expr that matches the given key/value
      "foo=42" => true, # segment is a key expr that matches the given key/value
    )
  end

  describe "created with 'foo=42'" do
    subject { described_class.new('foo=42') }

    has_these_basic_properties(
      :empty?    => false,
      :name      => "foo=42",
      :key       => "foo",
      :key_value => "42",
    )

    match_eh_returns(
      ""       => false,
      "foo"    => false,
      "bar"    => false,
      ":foo"   => true, # segment is a key/value that matches the given key expr
      "foo=23" => false,
      "foo=42" => false,
    )
  end
end
