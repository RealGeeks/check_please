module CheckPlease
  RSpec.shared_examples "AbstractSegment" do
    describe ".new (from AbstractSegment)" do
      it "returns the instance when given an instance of itself" do
        returned = described_class.new(valid_instance)
        expect( returned ).to be( valid_instance ) # object identity check
      end

      it "raises ArgumentError when given an Integer" do
        expect { described_class.new(42) }.to \
          raise_error( ArgumentError )
      end

      it "raises ArgumentError when given a string containing a space between non-space characters " do
        expect { described_class.new("hey bob") }.to \
          raise_error( ArgumentError )
      end
    end
  end

  module ItReturnsForMatchEh
    def it_returns(expected, when_given:)
      it "returns #{expected.inspect} when given #{when_given.inspect}" do
        actual = subject.match?(when_given)
        case actual
        when true, false, nil
          expect( actual ).to be( expected ) # identity
        else
          expect( actual ).to eq( expected ) # equality
        end
      end
    end
  end

  RSpec.describe Path::Segment do
    include_examples "AbstractSegment" do
      let(:valid_instance) { described_class.new("foo") }
    end

    describe ".new" do
      it "returns an instance with name='' when given no arguments" do
        seg = described_class.new()
        expect( seg ).to be_a(described_class)
        expect( seg.name ).to eq( "" )
      end

      it "returns an instance with name='foo' when given 'foo'" do
        seg = described_class.new("foo")
        expect( seg ).to be_a(described_class)
        expect( seg.name ).to eq( "foo" )
      end

      it "returns an instance with name='foo' when given '   foo '" do
        seg = described_class.new("   foo ")
        expect( seg ).to be_a(described_class)
        expect( seg.name ).to eq( "foo" )
      end

      it "raises ArgumentError when given a string that DOES contain a colon" do
        expect { described_class.new(":id") }.to \
          raise_error( ArgumentError )
      end
    end

    describe "#key" do
      it "returns nil when name='foo'" do
        subject = described_class.new("foo")
        expect( subject.key ).to be nil
      end

      it "returns :id when name='id=42'" do
        subject = described_class.new("id=42")
        expect( subject.key ).to eq( :id )
      end

      # REMINDER: name=':id' is invalid
    end

    describe "#match?" do
      extend ItReturnsForMatchEh

      context "with name='foo'" do
        subject { described_class.new("foo") }

        it_returns true,  when_given: "foo"
        it_returns false, when_given: "bar"
        it_returns false, when_given: ":id"
        it_returns false, when_given: "id=23"
        it_returns false, when_given: "id=42"

        it_returns false, when_given: Path::SegmentExpr.new(":id")
      end

      context "with name='id=42'" do
        subject { described_class.new("id=42") }

        it_returns false, when_given: "foo"
        it_returns false, when_given: "bar"
        it_returns true,  when_given: ":id"
        it_returns false, when_given: "id=23"
        it_returns true,  when_given: "id=42"

        it_returns true,  when_given: Path::SegmentExpr.new(":id")
      end

      # REMINDER: name=':id' is invalid
    end
  end

  RSpec.describe Path::SegmentExpr do
    include_examples "AbstractSegment" do
      let(:valid_instance) { described_class.new(":id") }
    end

    describe ".new" do
      it "raises ArgumentError when given a string that DOES NOT contain a colon" do
        expect { described_class.new("id") }.to \
          raise_error( ArgumentError )
      end

      it "raises ArgumentError when given a string that DOES NOT contain a LEADING colon" do
        expect { described_class.new("id:") }.to \
          raise_error( ArgumentError )
        expect { described_class.new("id:wibble") }.to \
          raise_error( ArgumentError )
      end

      it "raises ArgumentError when given a string that contains more than one colon" do
        expect { described_class.new(":id:wibble") }.to \
          raise_error( ArgumentError )
      end
    end

    describe "#key" do
      it "returns #name as a Symbol with the initial colon removed" do
        segex = described_class.new(":id")
        expect( segex.key ).to eq( :id )
      end
    end

    describe "#match?" do
      extend ItReturnsForMatchEh

      # REMINDER: name='foo' is invalid
      # REMINDER: name='id=42' is also invalid

      context "for a segment with name=':id'" do
        subject { described_class.new(":id") }

        it_returns false, when_given: "foo"
        it_returns false, when_given: "bar"
        it_returns false, when_given: ":id"
        it_returns true,  when_given: "id=23"
        it_returns true,  when_given: "id=42"

        it_returns false, when_given: Path::Segment.new("foo")
        it_returns false, when_given: Path::Segment.new("bar")
        # not testing Path::Segment.new(":id") because it's invalid
        it_returns true,  when_given: Path::Segment.new("id=23")
        it_returns true,  when_given: Path::Segment.new("id=42")
      end
    end
  end

  RSpec.describe Path do
    let(:root) { Path.new }

    describe "a new Path with no segments" do
      it "describes itself as '/'" do
        expect( root.to_s ).to eq( "/" )
      end

      it "indeed has no segments" do
        expect( root.segments ).to be_empty
      end

      it "has a depth of 1" do
        expect( root.depth ).to eq( 1 )
      end

      it "answers true for #root?" do
        expect( root.root? ).to be true
      end
    end

    describe "a Path plus a string" do
      let(:new_path) { root + "wibble" }

      it "is a new Path with the string added" do
        expect( new_path      ).to_not be( root )
        expect( new_path.to_s ).to     eq( "/wibble" )
      end

      it "has a #basename of the string" do
        expect( new_path.basename ).to eq( "wibble" )
      end

      it "has a #depth of 2" do
        expect( new_path.depth ).to eq( 2 )
      end
    end

    specify "a Path can be created from a string with no slashes" do
      path = Path.new("foo")
      expect( path.to_s  ).to eq( "/foo" )
      expect( path.depth ).to eq( 2 )
    end

    specify "a Path can be created from a string with a leading slash" do
      path = Path.new("/foo")
      expect( path.to_s  ).to eq( "/foo" )
      expect( path.depth ).to eq( 2 )
    end

    specify "a longer Path can be created from a string with multiple slashes" do
      path = Path.new("/foo/bar/yak")
      expect( path.to_s  ).to eq( "/foo/bar/yak" )
      expect( path.depth ).to eq( 4 )
    end

    specify "a path of '/foo/id=42' is valid" do
      path = Path.new("/foo/id=42")
      expect( path.to_s  ).to eq( "/foo/id=42" )
      expect( path.depth ).to eq( 3 )
    end

    specify "a path of '/foo/:id' is NOT valid" do
      expect { Path.new("/foo/:id") }.to raise_error( ArgumentError )
    end
  end

  RSpec.describe PathExpr do
    let(:root) { PathExpr.new }

    describe "a new PathExpr with no segments" do
      it "describes itself as '/'" do
        expect( root.to_s ).to eq( "/" )
      end

      it "indeed has no segments" do
        expect( root.segments ).to be_empty
      end

      it "has a depth of 1" do
        expect( root.depth ).to eq( 1 )
      end

      it "answers true for #root?" do
        expect( root.root? ).to be true
      end
    end

    describe "a PathExpr plus a string" do
      let(:new_path) { root + "wibble" }

      it "is a new PathExpr with the string added" do
        expect( new_path      ).to_not be( root )
        expect( new_path.to_s ).to     eq( "/wibble" )
      end

      it "has a #basename of the string" do
        expect( new_path.basename ).to eq( "wibble" )
      end

      it "has a #depth of 2" do
        expect( new_path.depth ).to eq( 2 )
      end
    end

    specify "a PathExpr can be created from a string with no slashes" do
      path = PathExpr.new("foo")
      expect( path.to_s  ).to eq( "/foo" )
      expect( path.depth ).to eq( 2 )
    end

    specify "a PathExpr can be created from a string with a leading slash" do
      path = PathExpr.new("/foo")
      expect( path.to_s  ).to eq( "/foo" )
      expect( path.depth ).to eq( 2 )
    end

    specify "a longer PathExpr can be created from a string with multiple slashes" do
      path = PathExpr.new("/foo/bar/yak")
      expect( path.to_s  ).to eq( "/foo/bar/yak" )
      expect( path.depth ).to eq( 4 )
    end

    specify "a path of '/foo/id=42' is NOT valid" do
      expect { Path.new("/foo/id=42") }.to raise_error( ArgumentError )
    end

    specify "a PathExpr of '/foo/:id' is valid" do
      path = Path.new("/foo/:id")
      expect( path.to_s  ).to eq( "/foo/:id" )
      expect( path.depth ).to eq( 3 )
    end
  end

=begin
  RSpec.describe Path do
    describe ".segment_matches? (with segment followed by segment_expr)" do
      def invoke!(segment, segment_expr)
        Path.segment_matches?( segment: segment, segment_expr: segment_expr )
      end

      it "answers true for [ 'foo', 'foo' ]" do
        expect( invoke!( "foo", "foo" ) ).to be true
      end

      it "answers true for [ 'id=42', ':id' ]" do
        expect( invoke!( "id=42", ":id" ) ).to be true
      end

      it "answers false for [ 'foo', 'bar' ]" do
        expect( invoke!( "foo", "bar" ) ).to be false
      end

      it "answers false for [ 'name=bob', ':id' ]" do
        expect( invoke!( "name=bob", ":id" ) ).to be false
      end

      it "complains for [ 'id=42', ':id:baby' ]" do
        expect { invoke!( "id=42", ":id:baby" ) }.to \
          raise_error( ArgumentError )
      end
    end

    describe "#matches_path_expr?" do
      def invoke!(path_string, path_expr)
        raise ArgumentError, "No leading slash in path_string: #{path_string.inspect}" unless path_string.start_with?("/")
        raise ArgumentError, "No leading slash in path_expr: #{path_expr.inspect}" unless path_string.start_with?("/")
        path = Path.new( path_string )
        path.matches_path_expr?(path_expr)
      end

      it "answers true for a simple path that matches the path expression literally" do
        expect( invoke!( "/foo", "/foo" ) ).to be true
      end

      it "answers true for a simple path that matches a path expression on key" do
        expect( invoke!( "/id=42", "/:id" ) ).to be true
      end

      it "answers true for a longer path that matches a path expression on key" do
        expect( invoke!( "/foo/bar/id=42", "/foo/bar/:id" ) ).to be true
      end

      it "answers true for a path with two keys in it" do
        expect( invoke!( "/foo/id=1/bar/id=2", "/foo/:id/bar/:id" ) ).to be true
      end

      it "answers false for a simple path that doesn't match the path expression literally" do
        expect( invoke!( "/foo", "/bar" ) ).to be false
      end

      it "answers false for a path that is longer than the path expression" do
        expect( invoke!( "/foo/bar", "/bar" ) ).to be false
      end

      it "answers false for a path that is shorter than the path expression" do
        expect( invoke!( "/foo", "/foo/bar" ) ).to be false
      end

      it "answers false for a simple path that doesn't match the path expression by key" do
        expect( invoke!( "/name=bob", "/:id" ) ).to be false
      end

      it "answers false for a longer path that doesn't match the path expression by key" do
        expect( invoke!( "/foo/bar/name=bob", "/foo/bar/:id" ) ).to be false
      end

      it "answers false for a path with two keys in it that doesn't match the second path expression by key" do
        expect( invoke!( "/foo/id=1/bar/name=bob", "/foo/:id/bar/:id" ) ).to be false
      end

      it "complains if a segment in the path expression contains more than one colon" do
        expect { invoke!( "/id=42",         "/:id:baby" )         }.to raise_error( ArgumentError )
        expect { invoke!( "/foo/bar/id=42", "/foo/bar/:id:baby" ) }.to raise_error( ArgumentError )
      end
    end

    describe "#key_name_for_match" do
      specify "'/' answers :id for '/:id'" do
        path = Path.new('/')
        flags = Flags.new(match_by_key: [ '/:id' ])
        expect( path.key_name_for_match(flags) ).to eq( :id )
      end

      specify "'/foo' answers :id for '/foo/:id'" do
        path = Path.new('/foo')
        flags = Flags.new(match_by_key: [ '/foo/:id' ])
        expect( path.key_name_for_match(flags) ).to eq( :id )
      end

      specify "'/foo/bar' answers :id for '/foo/bar/:id'" do
        fail "write me"
      end

      specify "'/foo/bar/id=42/yak' answers :id2 for '/foo/bar/:id1/yak/:id2'" do
        fail "write me"
      end
    end
=end
end
