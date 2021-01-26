RSpec.describe CheckPlease::PathSegment do
  def self.match_eh_returns(values_and_expected_returns = {})
    values_and_expected_returns.each do |value, expected|
      specify "#match?(#{value.inspect}) returns #{expected.inspect}" do

        actual = subject.match?(value) # <-- where the magic happens

        _compare expected, actual
      end
    end
  end

  describe ".reify" do
    it "returns the instance when given an instance of itself" do
      foo = described_class.reify("foo")
      returned = described_class.reify(foo)
      expect( returned ).to be( foo ) # object identity check
    end

    it "raises CheckPlease::PathSegment::InvalidPathSegment when given a string containing a space between non-space characters " do
      expect { described_class.reify("hey bob") }.to \
        raise_error( CheckPlease::InvalidPathSegment )
    end

    it "returns an instance with name='foo' when given 'foo' (a string)" do
      instance = described_class.reify("foo")
      expect( instance      ).to     be_a(described_class)
      expect( instance.name ).to     eq( "foo" )
      expect( instance      ).to_not be_empty
    end

    it "returns an instance with name='foo' when given '   foo ' (a string with leading/trailing whitespace)" do
      instance = described_class.reify("   foo ")
      expect( instance      ).to be_a(described_class)
      expect( instance.name ).to eq( "foo" )
      expect( instance      ).to_not be_empty
    end

    it "returns an instance with name='foo' when given :foo (a symbol)" do
      instance = described_class.reify(:foo)
      expect( instance      ).to     be_a(described_class)
      expect( instance.name ).to     eq( "foo" )
      expect( instance      ).to_not be_empty
    end

    it "returns an instance with name='42' when given 42 (an integer)" do
      instance = described_class.reify(42)
      expect( instance      ).to     be_a(described_class)
      expect( instance.name ).to     eq( "42" )
      expect( instance      ).to_not be_empty
    end

    it "raises when given a boolean" do
      expect { described_class.reify(true) }.to \
        raise_error(ArgumentError, /reify was given: true.*but only accepts/m)
    end

    it "returns a list of instances when given [ 'foo', 'bar' ]" do
      list = described_class.reify( %w[ foo bar ] )
      expect( list ).to be_an(Array)
      expect( list.length ).to eq( 2 )

      foo, bar = *list
      expect( foo      ).to be_a(described_class)
      expect( bar      ).to be_a(described_class)
      expect( foo.name ).to eq( "foo" )
      expect( bar.name ).to eq( "bar" )
    end
  end

  describe "created with no arguments" do
    subject { described_class.new() }

    has_these_basic_properties(
      :empty?        => true,
      :name          => "",
      :key           => nil,
      :key_value     => nil,
      :key_expr?     => false,
      :key_val_expr? => false,
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
      :empty?        => false,
      :name          => "foo",
      :key           => nil,
      :key_value     => nil,
      :key_expr?     => false,
      :key_val_expr? => false,
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

  describe "created with ':foo' (a 'key expression')" do
    subject { described_class.new(':foo') }

    has_these_basic_properties(
      :empty?        => false,
      :name          => ":foo",
      :key           => "foo",
      :key_value     => nil,
      :key_expr?     => true,
      :key_val_expr? => false,
    )

    match_eh_returns(
      ""       => false,
      "foo"    => false,
      "bar"    => false,
      ":foo"   => false, # key exprs can't match other key exprs
      "foo=23" => true,  # segment is a key expr that matches the given key/value
      "foo=42" => true,  # segment is a key expr that matches the given key/value
    )
  end

  describe "created with 'foo=42' (a 'key/value expression')" do
    subject { described_class.new('foo=42') }

    has_these_basic_properties(
      :empty?        => false,
      :name          => "foo=42",
      :key           => "foo",
      :key_value     => "42",
      :key_expr?     => false,
      :key_val_expr? => true,
    )

    match_eh_returns(
      ""       => false,
      "foo"    => false,
      "bar"    => false,
      ":foo"   => true,  # segment is a key/value that matches the given key expr
      "foo=23" => false, # key/val exprs can't match other key/val exprs
      "foo=42" => false, # key/val exprs can't match other key/val exprs
    )
  end
end
