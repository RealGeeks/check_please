RSpec.describe CheckPlease::Path do
  specify ".root returns a root path" do
    root = described_class.root
    expect( root       ).to be_a( described_class )
    expect( root.to_s  ).to eq( "/" )
    expect( root.depth ).to eq( 1 )
    expect( root.root? ).to be true
  end

  describe "an instance created with" do
    describe "no arguments" do
      subject { described_class.new() }

      has_these_basic_properties(
        :to_s  => "/",
        :depth => 1,
        :root? => true,
      )
    end

    describe "an empty string" do
      subject { described_class.new("") }

      has_these_basic_properties(
        :to_s  => "/",
        :depth => 1,
        :root? => true,
      )
    end

    describe "'foo' (a string)" do
      subject { described_class.new('foo') }

      has_these_basic_properties(
        :to_s  => "/foo",
        :depth => 2,
        :root? => false,
      )
    end

    describe ":foo (a symbol)" do
      subject { described_class.new(:foo) }

      has_these_basic_properties(
        :to_s  => "/foo",
        :depth => 2,
        :root? => false,
      )
    end

    describe "'/foo'" do
      subject { described_class.new('/foo') }

      has_these_basic_properties(
        :to_s  => "/foo",
        :depth => 2,
        :root? => false,
      )
    end

    describe "'/foo/bar'" do
      subject { described_class.new('/foo/bar') }

      has_these_basic_properties(
        :to_s  => "/foo/bar",
        :depth => 3,
        :root? => false,
      )

      specify "its .parent is a Path with name='/foo'" do
        expect( subject.parent      ).to be_a( described_class )
        expect( subject.parent.to_s ).to eq( '/foo' )
      end
    end

    describe "'/foo/bar/yak'" do
      subject { described_class.new('/foo/bar/yak') }

      has_these_basic_properties(
        :to_s  => "/foo/bar/yak",
        :depth => 4,
        :root? => false,
      )
    end

    describe "'1' (a string)" do
      subject { described_class.new('1') }

      has_these_basic_properties(
        :to_s  => "/1",
        :depth => 2,
        :root? => false,
      )
    end

    describe "1 (an integer)" do
      subject { described_class.new(1) }

      has_these_basic_properties(
        :to_s  => "/1",
        :depth => 2,
        :root? => false,
      )
    end

    describe "'1.1' (a string)" do
      subject { described_class.new('1.1') }

      has_these_basic_properties(
        :to_s  => "/1.1",
        :depth => 2,
        :root? => false,
      )
    end

    describe "1.1 (a float)" do
      subject { described_class.new(1.1) }

      has_these_basic_properties(
        :to_s  => "/1.1",
        :depth => 2,
        :root? => false,
      )
    end

    describe "'/:id' (a string representing a key expression)" do
      subject { described_class.new('/:id') }

      has_these_basic_properties(
        :to_s  => "/:id",
        :depth => 2,
        :root? => false,
      )
    end

    describe "'/foo/:id/bar/:name' (a string representing two key expressions)" do
      subject { described_class.new('/foo/:id/bar/:name') }

      has_these_basic_properties(
        :to_s  => "/foo/:id/bar/:name",
        :depth => 5,
        :root? => false,
      )
    end
  end

  describe "#==" do
    def self.it_returns(expected, when_given:)
      desc = when_given.is_a?(described_class) \
        ? "path '%s'" % when_given.to_s \
        : when_given.inspect
      specify "returns #{expected.inspect} when given #{desc}" do
        actual = (subject == when_given)
        _compare expected, actual
      end
    end

    context "for path '/foo'" do
      subject(:foo) { pathify('/foo') }

      it_returns true,  when_given: pathify('/foo')
      it_returns true,  when_given: '/foo'
      it_returns false, when_given: pathify('/foo/bar')
      it_returns false, when_given: '/foo/bar'
    end

    context "for path '/foo/bar'" do
      subject(:foobar) { pathify('/foo/bar') }

      it_returns false, when_given: pathify('/foo')
      it_returns false, when_given: '/foo'
      it_returns true,  when_given: pathify('/foo/bar')
      it_returns true,  when_given: '/foo/bar'
    end

    it "returns false if the operand has the same length but a different name" do
      foo = pathify('/foo')
      bar = pathify('/bar')
      expect( foo ).to_not eq( bar )
    end

    it "returns false if the operand should #match? but is literally different" do
      foo_id_42   = pathify('/foo/id=42')
      foo_id_expr = pathify('/foo/:id')
      expect( foo_id_42 ).to_not eq( foo_id_expr )
    end
  end

  describe "#+" do
    specify "path '/' plus the string 'wibble' returns path '/wibble'" do
      root = described_class.root
      path = root + "wibble"
      expect( path      ).to be_a(described_class)
      expect( path.to_s ).to eq( "/wibble" )
    end

    specify "path '/foo' plus the string 'bar' returns path '/foo/bar'" do
      foo = pathify('/foo')
      bar = foo + 'bar'
      expect( bar      ).to be_a(described_class)
      expect( bar.to_s ).to eq( "/foo/bar" )
    end
  end

  describe ".reify" do
    it "returns the instance when given an instance of itself" do
      foo = described_class.reify("foo")
      returned = described_class.reify(foo)
      expect( returned ).to be( foo ) # object identity check
    end

    it "raises CheckPlease::PathSegment::InvalidPath when given a string containing a space between non-space characters " do
      expect { described_class.reify("hey bob") }.to \
        raise_error( CheckPlease::InvalidPath )
    end

    it "returns an instance with to_s='/foo' when given 'foo' (a string)" do
      instance = described_class.reify("foo")
      expect( instance      ).to be_a(described_class)
      expect( instance.to_s ).to eq( "/foo" )
    end

    it "returns an instance with to_s='/foo' when given '   foo ' (a string with leading/trailing whitespace)" do
      instance = described_class.reify("   foo ")
      expect( instance      ).to be_a(described_class)
      expect( instance.to_s ).to eq( "/foo" )
    end

    it "returns an instance with to_s='/foo' when given :foo (a symbol)" do
      instance = described_class.reify(:foo)
      expect( instance      ).to be_a(described_class)
      expect( instance.to_s ).to eq( "/foo" )
    end

    it "returns an instance with to_s='/42' when given 42 (an integer)" do
      instance = described_class.reify(42)
      expect( instance      ).to be_a(described_class)
      expect( instance.to_s ).to eq( "/42" )
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
      expect( foo.to_s ).to eq( "/foo" )
      expect( bar.to_s ).to eq( "/bar" )
    end
  end

  describe "#parent" do
    specify "the parent of '/foo/bar' is 'foo'" do
      foobar = pathify('/foo/bar')
      expect( foobar.parent      ).to be_a(described_class)
      expect( foobar.parent.to_s ).to eq( '/foo' )
    end

    specify "the parent of '/foo' is root" do
      foo = pathify('/foo')
      expect( foo.parent      ).to be_a(described_class)
      expect( foo.parent.to_s ).to eq( '/' )
      expect( foo.parent      ).to be_root
    end

    specify "the parent of root is nil" do
      root = described_class.root
      expect( root.parent ).to be nil
    end
  end

  describe "#ancestors" do
    specify "the ancestors of '/foo/bar' are root and '/foo'" do
      expect( pathify('/foo/bar').ancestors.map(&:to_s) ).to eq( [ "/", "/foo" ])
    end

    specify "the ancestors of '/foo' are (just) root" do
      expect( pathify('/foo').ancestors.map(&:to_s) ).to eq( [ "/" ])
    end

    specify "the ancestors of root are empty" do
      expect( described_class.root.ancestors ).to be_empty
    end
  end

  describe "#excluded?" do
    it "answers true if the path's depth exceeds the max_depth flag (NOTE: root has depth=1)" do
      flags = flagify(max_depth: 2)
      expect( pathify('/foo')              ).to_not be_excluded(flags)
      expect( pathify('/foo/bar')          ).to     be_excluded(flags)
      expect( pathify('/foo/bar/yak')      ).to     be_excluded(flags)
      expect( pathify('/foo/bar/yak/spam') ).to     be_excluded(flags)

      flags = flagify(max_depth: 3)
      expect( pathify('/foo')              ).to_not be_excluded(flags)
      expect( pathify('/foo/bar')          ).to_not be_excluded(flags)
      expect( pathify('/foo/bar/yak')      ).to     be_excluded(flags)
      expect( pathify('/foo/bar/yak/spam') ).to     be_excluded(flags)

      flags = flagify(max_depth: 4)
      expect( pathify('/foo')              ).to_not be_excluded(flags)
      expect( pathify('/foo/bar')          ).to_not be_excluded(flags)
      expect( pathify('/foo/bar/yak')      ).to_not be_excluded(flags)
      expect( pathify('/foo/bar/yak/spam') ).to     be_excluded(flags)
    end

    # NOTE: the /name, /words/*, and /meta/* examples were swiped from spec/check_please/comparison_spec.rb

    it "answers true if select_paths is present and the path IS NOT on/under the list" do
      flags = flagify(select_paths: "/words")
      expect( pathify('/name')     ).to     be_excluded(flags)
      expect( pathify('/words')    ).to_not be_excluded(flags)
      expect( pathify('/words/3')  ).to_not be_excluded(flags)
      expect( pathify('/words/6')  ).to_not be_excluded(flags)
      expect( pathify('/words/11') ).to_not be_excluded(flags)
      expect( pathify('/meta')     ).to     be_excluded(flags)
      expect( pathify('/meta/foo') ).to     be_excluded(flags)
      expect( pathify('/meta/bar') ).to     be_excluded(flags)
    end

    it "answers true if reject_paths is present and the path IS on/under the list" do
      flags = flagify(reject_paths: "/words")
      expect( pathify('/name')     ).to_not be_excluded(flags)
      expect( pathify('/words')    ).to     be_excluded(flags)
      expect( pathify('/words/3')  ).to     be_excluded(flags)
      expect( pathify('/words/6')  ).to     be_excluded(flags)
      expect( pathify('/words/11') ).to     be_excluded(flags)
      expect( pathify('/meta')     ).to_not be_excluded(flags)
      expect( pathify('/meta/foo') ).to_not be_excluded(flags)
      expect( pathify('/meta/bar') ).to_not be_excluded(flags)
    end
  end

  describe "#match?" do
    def self.it_returns(expected, when_given:)
      line = caller[0].split(":")[1]
      specify "[line #{line}] returns #{expected} when given #{when_given.inspect}" do
        actual = subject.match?(when_given)
        _compare expected, actual
      end
    end

    context "for path '/foo'" do
      subject { pathify('/foo') }

      it_returns true,  when_given: "/foo" # literal string equality
      it_returns false, when_given: "/bar"
      it_returns false, when_given: "/foo/bar"
      it_returns false, when_given: "/foo/:id"
      it_returns false, when_given: "/foo/id=23"
      it_returns false, when_given: "/foo/id=42"
      it_returns false, when_given: "/foo/id=42/bar"
      it_returns false, when_given: "/foo/id=42/bar/id=23"
      it_returns false, when_given: "/foo/:name"
      it_returns false, when_given: "/foo/:name/bar/:id"
    end

    context "for path '/foo/id=42'" do
      subject { pathify('/foo/id=42') }

      it_returns false, when_given: "/foo"
      it_returns false, when_given: "/bar"
      it_returns false, when_given: "/foo/bar"
      it_returns true,  when_given: "/foo/:id"   # key/val expr in subject matches key expr in argument
      it_returns false, when_given: "/foo/id=23"
      it_returns true,  when_given: "/foo/id=42" # literal string equality
      it_returns false, when_given: "/foo/id=42/bar"
      it_returns false, when_given: "/foo/id=42/bar/id=23"
      it_returns false, when_given: "/foo/:id/bar/:id"
      it_returns false, when_given: "/foo/:name"
      it_returns false, when_given: "/foo/:name/bar/:id"
    end

    context "for path '/foo/id=42/bar/id=23'" do
      subject { pathify('/foo/id=42/bar/id=23') }

      it_returns false, when_given: "/foo"
      it_returns false, when_given: "/bar"
      it_returns false, when_given: "/foo/bar"
      # it_returns true,  when_given: "/foo/:id"
      it_returns false, when_given: "/foo/id=23"
      it_returns false, when_given: "/foo/id=42"
      it_returns false, when_given: "/foo/id=42/bar"
      it_returns true,  when_given: "/foo/id=42/bar/id=23"   # literal string equality
      it_returns false, when_given: "/foo/name=42/bar/id=23"
      it_returns true,  when_given: "/foo/:id/bar/:id"       # key/val expr in subject matches key expr in argument
      it_returns false, when_given: "/foo/:name"             # first key expr in subject does not match
      it_returns false, when_given: "/foo/:name/bar/:id"     # first key expr in subject does not match
    end

    context "for path '/foo/name=42/bar/id=23'" do
      subject { pathify('/foo/name=42/bar/id=23') }

      it_returns false, when_given: "/foo"
      it_returns false, when_given: "/bar"
      it_returns false, when_given: "/foo/bar"
      it_returns false, when_given: "/foo/:id"
      it_returns false, when_given: "/foo/id=23"
      it_returns false, when_given: "/foo/id=42"
      it_returns false, when_given: "/foo/id=42/bar"
      it_returns false, when_given: "/foo/id=42/bar/id=23"
      it_returns true,  when_given: "/foo/name=42/bar/id=23" # literal string equality
      it_returns false, when_given: "/foo/:id/bar/:id"       # first key expr in subject does not match
      # it_returns true,  when_given: "/foo/:name"             # first key/val expr in subject matches first key expr in argument
      it_returns true,  when_given: "/foo/:name/bar/:id"     # both key/val exprs in subject match key exprs in argument
    end
  end

  describe "#key_for_compare (note: MBK=match_by_key)" do
    def self.it_returns(expected, for_path:)
      line = caller[0].split(":")[1]
      specify "[line #{line}] returns #{expected.inspect} for path '#{for_path}'" do
        the_path = pathify(for_path)
        actual = the_path.key_for_compare(flags)
        _compare expected, actual
      end
    end

    context "when given flags with no MBK expressions" do
      let(:flags) { flagify({}) }

      it_returns nil, for_path: '/'
      it_returns nil, for_path: '/id=42'
      it_returns nil, for_path: '/foo'
      it_returns nil, for_path: '/foo/id=42'
      it_returns nil, for_path: '/foo/id=42/bar'
      it_returns nil, for_path: '/foo/id=42/bar/id=23'
      it_returns nil, for_path: '/foo/name=42/bar/id=23'
    end

    context "when given flags with a '/:id' MBK expression" do
      let(:flags) { flagify(match_by_key: "/:id") }

      it_returns "id", for_path: '/'
      it_returns nil,  for_path: '/id=42'
      it_returns nil,  for_path: '/foo'
      it_returns nil,  for_path: '/foo/id=42'
      it_returns nil,  for_path: '/foo/id=42/bar'
      it_returns nil,  for_path: '/foo/id=42/bar/id=23'
      it_returns nil,  for_path: '/foo/name=42/bar/id=23'
    end

    context "when given flags with a '/foo/:id' MBK expression" do
      let(:flags) { flagify(match_by_key: "/foo/:id") }

      it_returns nil,  for_path: '/'
      it_returns nil,  for_path: '/id=42'
      it_returns "id", for_path: '/foo'
      it_returns nil,  for_path: '/foo/id=42'
      it_returns nil,  for_path: '/foo/id=42/bar'
      it_returns nil,  for_path: '/foo/id=42/bar/id=23'
      it_returns nil,  for_path: '/foo/name=42/bar/id=23'
    end

    context "when given flags with a '/foo/:id/bar/:id' MBK expression" do
      let(:flags) { flagify(match_by_key: "/foo/:id/bar/:id") }

      it_returns nil,  for_path: '/'
      it_returns nil,  for_path: '/id=42'
      it_returns "id", for_path: '/foo'
      it_returns nil,  for_path: '/foo/id=42'
      it_returns "id", for_path: '/foo/id=42/bar'
      it_returns nil,  for_path: '/foo/id=42/bar/id=23'
      it_returns nil,  for_path: '/foo/name=42/bar'
      it_returns nil,  for_path: '/foo/name=42/bar/id=23'
    end

    context "when given flags with a '/foo/:name/bar/:id' MBK expression" do
      let(:flags) { flagify(match_by_key: "/foo/:name/bar/:id") }

      it_returns nil,    for_path: '/'
      it_returns nil,    for_path: '/id=42'
      it_returns "name", for_path: '/foo'
      it_returns nil,    for_path: '/foo/id=42'
      it_returns nil,    for_path: '/foo/id=42/bar'
      it_returns nil,    for_path: '/foo/id=42/bar/id=23'
      it_returns "id",   for_path: '/foo/name=42/bar'
      it_returns nil,    for_path: '/foo/name=42/bar/id=23'
      it_returns nil,    for_path: '/foo/name=42/bar/id=23'
    end
  end
end
