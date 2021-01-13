RSpec.describe CheckPlease::Comparison do
  def invoke!(ref, can, flags = {})
    CheckPlease::Comparison.perform(ref, can, flags)
  end

  context "when given two scalars" do
    let(:reference) { 42 }
    let(:candidate) { 43 }

    it "has one diff for the top-level mismatch" do
      diffs = invoke!(reference, candidate)
      expect( diffs.length ).to eq( 1 )
      expect( diffs[0] ).to eq_diff( :mismatch, "/", ref: 42, can: 43 )
    end
  end

  context "when given two arrays of scalars" do
    context "same length, different elements" do
      let(:reference) { [ 1, 2, 3 ] }
      let(:candidate) { [ 1, 2, 5 ] }

      it "has one diff for the second-level mismatch" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :mismatch, "/3", ref: 3, can: 5 )
      end
    end

    context "reference longer than candidate" do
      let(:reference) { [ 1, 2, 3 ] }
      let(:candidate) { [ 1, 2 ] }

      it "has one diff for the missing element" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :missing, "/3", ref: 3, can: nil )
      end
    end

    context "reference shorter than candidate" do
      let(:reference) { [ 1, 2 ] }
      let(:candidate) { [ 1, 2, 3 ] }

      it "has one diff for the extra element" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :extra, "/3", ref: nil, can: 3 )
      end
    end
  end

  context "when given two hashes of scalars" do
    context "same length, one key mismatch" do
      let(:reference) { { foo: 1, bar: 2, yak:  3 } }
      let(:candidate) { { foo: 1, bar: 2, quux: 3 } }

      it "has two diffs: one missing, one extra" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 2 )
        expect( diffs["/yak"]  ).to eq_diff( :missing, "/yak",  ref: 3,   can: nil )
        expect( diffs["/quux"] ).to eq_diff( :extra,   "/quux", ref: nil, can: 3 )
      end
    end

    context "same length, same keys, one value mismatch" do
      let(:reference) { { foo: 1, bar: 2, yak: 3 } }
      let(:candidate) { { foo: 1, bar: 2, yak: 5 } }

      it "has one diff for the mismatch" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :mismatch, "/yak", ref: 3, can: 5 )
      end
    end
  end

  context "when given two hashes of arrays" do
    context "top-level hash keys differ" do
      let(:reference) { { foo: [ 1, 2, 3 ], bar: [ 2, 3, 4 ] } }
      let(:candidate) { { foo: [ 1, 2, 3 ], yak: [ 2, 3, 5 ] } }

      it "has two diffs: one missing, one extra" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 2 )
        expect( diffs["/bar"] ).to eq_diff( :missing, "/bar", ref: [2,3,4], can: nil )
        expect( diffs["/yak"] ).to eq_diff( :extra,   "/yak", ref: nil,     can: [2,3,5] )
      end
    end

    context "nested array elements differ" do
      let(:reference) { { foo: [ 1, 2, 3 ], bar: [ 2, 3, 4 ] } }
      let(:candidate) { { foo: [ 1, 2, 3 ], bar: [ 2, 3, 5 ] } }

      it "has one diff for the mismatch in the nested array elements" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :mismatch, "/bar/3", ref: 4, can: 5 )
      end
    end
  end

  context "when given two arrays of hashes" do
    context "same length, nested hash keys differ" do
      let(:reference) { [ { foo: 1, bar: 2, yak:  3 } ] }
      let(:candidate) { [ { foo: 1, bar: 2, quux: 3 } ] }

      it "has two diffs: one missing, one extra" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 2 )

        expect( diffs["/1/yak"]  ).to eq_diff( :missing, "/1/yak",  ref: 3,   can: nil )
        expect( diffs["/1/quux"] ).to eq_diff( :extra,   "/1/quux", ref: nil, can: 3 )
      end
    end

    context "same length, nested hash keys same, one value mismatch" do
      let(:reference) { [ { foo: 1, bar: 2, yak: 3 } ] }
      let(:candidate) { [ { foo: 1, bar: 2, yak: 5 } ] }

      it "has one diff for the mismatch" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :mismatch, "/1/yak", ref: 3, can: 5 )
      end
    end

    context "reference longer than candidate" do
      let(:reference) { [ { foo: 1 }, { bar: 2 } ] }
      let(:candidate) { [ { foo: 1 } ] }

      it "has one diff for the missing hash" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :missing, "/2", ref: { bar: 2 }, can: nil )
      end
    end

    context "candidate longer than reference" do
      let(:reference) { [ { foo: 1 } ] }
      let(:candidate) { [ { foo: 1 }, { bar: 2 } ] }

      it "has one diff for the extra hash" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :extra, "/2", ref: nil, can: { bar: 2 } )
      end
    end
  end

  describe "comparing arrays by keys" do
    shared_examples "compare_arrays_by_key" do
      specify "comparing [A,B] with [B,A] correctly matches up A and B using the :id value, resulting in zero diffs" do
        diffs = invoke!( [a,b], [b,a], match_by_key: [ "/:id" ] )
        expect( diffs.length ).to eq( 0 )
      end

      specify "comparing [A,B] with [A] complains that B is missing" do
        diffs = invoke!( [a,b], [a], match_by_key: [ "/:id" ] )
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :missing, "/id=#{b[b_key_name]}", ref: b, can: nil )
      end

      specify "comparing [A,B] with [B] complains that A is missing" do
        diffs = invoke!( [a,b], [b], match_by_key: [ "/:id" ] )
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :missing, "/id=#{a[a_key_name]}", ref: a, can: nil )
      end

      specify "comparing [A] with [A,B] complains that B is extra" do
        diffs = invoke!( [a], [a,b], match_by_key: [ "/:id" ] )
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :extra, "/id=#{b[b_key_name]}", ref: nil, can: b )
      end

      specify "comparing [B] with [A,B] complains that B is extra" do
        diffs = invoke!( [b], [a,b], match_by_key: [ "/:id" ] )
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :extra, "/id=#{a[a_key_name]}", ref: nil, can: a )
      end

      specify "comparing [A] with [A,A,B] complains that there are too many As" do
        diffs = invoke!( [a], [a,b], match_by_key: [ "/:id" ] )
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :extra, "/id=#{b[b_key_name]}", ref: nil, can: b )
      end

      specify "comparing two lists where the top-level elements can be matched by key but have different child values... works" do
        ref = { "id" => 1, "deeply" => { "nested" => [ a, b ] } }
        can = { "id" => 1, "deeply" => { "nested" => [ c, a ] } }

        diffs = invoke!( [ref], [can], match_by_key: [ "/:id", "/:id/deeply/nested/:id" ] )
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :mismatch, "/id=1/deeply/nested/id=2/foo", ref: "bat", can: "yak" )
      end

      specify "comparing [A,B] with [B,A] raises NoSuchKeyError if given a bogus key expression" do
        expect { invoke!( [a,b], [b,a], match_by_key: [ "/:identifier" ] ) }.to \
          raise_error(CheckPlease::NoSuchKeyError, /The reference hash at position 0 has no "identifier" key/)
      end

      specify "comparing [A,A] with [A] raises DuplicateKeyError" do
        expect { invoke!( [a,a], [a], match_by_key: [ "/:id" ] ) }.to \
          raise_error(CheckPlease::DuplicateKeyError, /Duplicate reference element found/)
      end

      specify "comparing [A,A] with [A,A] raises DuplicateKeyError" do
        expect { invoke!( [a,a], [a,a], match_by_key: [ "/:id" ] ) }.to \
          raise_error(CheckPlease::DuplicateKeyError, /Duplicate reference element found/)
      end

      specify "comparing [A] with [A,A] raises DuplicateKeyError" do
        expect { invoke!( [a], [a,a], match_by_key: [ "/:id" ] ) }.to \
          raise_error(CheckPlease::DuplicateKeyError, /Duplicate candidate element found/)
      end

      specify "comparing [42] with [A] raises TypeMismatchError" do
        expect { invoke!( [42], [a], match_by_key: [ "/:id" ] ) }.to \
          raise_error(CheckPlease::TypeMismatchError, /The element at position \d+ in the reference array is not a hash/)
      end

      specify "comparing [A] with [42] raises TypeMismatchError" do
        expect { invoke!( [a], [42], match_by_key: [ "/:id" ] ) }.to \
          raise_error(CheckPlease::TypeMismatchError, /The element at position \d+ in the candidate array is not a hash/)
      end
    end

    context "when both ref and can use strings for keys" do
      let(:a) { { "id" => 1, "foo" => "bar" } }
      let(:b) { { "id" => 2, "foo" => "bat" } }
      let(:c) { { "id" => 2, "foo" => "yak" } }
      let(:a_key_name) { "id" }
      let(:b_key_name) { "id" }

      include_examples "compare_arrays_by_key"
    end

    ###############################################
    ##                                           ##
    ##  ########   #####    ######      #####    ##
    ##     ##     ##   ##   ##   ##    ##   ##   ##
    ##     ##    ##     ##  ##    ##  ##     ##  ##
    ##     ##    ##     ##  ##    ##  ##     ##  ##
    ##     ##    ##     ##  ##    ##  ##     ##  ##
    ##     ##     ##   ##   ##   ##    ##   ##   ##
    ##     ##      #####    ######      #####    ##
    ##                                           ##
    ###############################################
    # TODO: decide how to handle non-string keys. Symbols? Integers? E_CAN_OF_WORMS
    ###############################################

    # context "when ref keys are symbols and can keys are strings" do
    #   let(:a) { { :id  => 1, :foo  => "bar" } }
    #   let(:b) { { "id" => 2, "foo" => "bat" } }
    #   let(:a_key_name) { :id }
    #   let(:b_key_name) { "id" }
    #
    #   include_examples "compare_arrays_by_key"
    # end

    # context "when ref keys are strings and can keys are symbols" do
    #   let(:a) { { "id" => 1, "foo" => "bar" } }
    #   let(:b) { { :id  => 2, :foo  => "bat" } }
    #   let(:a_key_name) { "id" }
    #   let(:b_key_name) { :id }
    #
    #   include_examples "compare_arrays_by_key"
    # end

    # context "when both ref and can use symbols for keys" do
    #   let(:a) { { :id => 1, :foo => "bar" } }
    #   let(:b) { { :id => 2, :foo => "bat" } }
    #   let(:a_key_name) { :id }
    #   let(:b_key_name) { :id }
    #
    #   include_examples "compare_arrays_by_key"
    # end
  end

  context "when given an Array :reference and an Integer :candidate" do
    let(:reference) { [ 42 ] }
    let(:candidate) { 42 }

    it "has one diff for the top-level mismatch" do
      diffs = invoke!(reference, candidate)
      expect( diffs.length ).to eq( 1 )
      expect( diffs[0] ).to eq_diff( :type_mismatch, "/", ref: [42], can: 42 )
    end
  end

  context "when given an Integer :reference and an Array :candidate" do
    let(:reference) { 42 }
    let(:candidate) { [ 42 ] }

    it "has one diff for the top-level mismatch" do
      diffs = invoke!(reference, candidate)
      expect( diffs.length ).to eq( 1 )
      expect( diffs[0] ).to eq_diff( :type_mismatch, "/", ref: 42, can: [42] )
    end
  end

  context "for two data structures four levels deep, with one diff at each level" do
    let(:reference) { { a: 1, b: { c: 3, d: { e: 5, f: { g: 7 } } } } }
    let(:candidate) { { a: 2, b: { c: 4, d: { e: 6, f: { g: 8 } } } } }

    it "has four diffs" do
      diffs = invoke!(reference, candidate)
      expect( diffs.length ).to eq( 4 )
      expect( diffs[0] ).to eq_diff( :mismatch, "/a",       ref: 1, can: 2 )
      expect( diffs[1] ).to eq_diff( :mismatch, "/b/c",     ref: 3, can: 4 )
      expect( diffs[2] ).to eq_diff( :mismatch, "/b/d/e",   ref: 5, can: 6 )
      expect( diffs[3] ).to eq_diff( :mismatch, "/b/d/f/g", ref: 7, can: 8 )
    end

    it "has no diffs when passed a max_depth of 1" do
      diffs = invoke!(reference, candidate, max_depth: 1)
      expect( diffs.length ).to eq( 0 )
    end

    it "only has the first diff when passed a max_depth of 2" do
      diffs = invoke!(reference, candidate, max_depth: 2)
      expect( diffs.length ).to eq( 1 )
      expect( diffs[0] ).to eq_diff( :mismatch, "/a", ref: 1, can: 2 )
    end

    it "only has the first two diffs when passed a max_depth of 3" do
      diffs = invoke!(reference, candidate, max_depth: 3)
      expect( diffs.length ).to eq( 2 )
      expect( diffs[0] ).to eq_diff( :mismatch, "/a",   ref: 1, can: 2 )
      expect( diffs[1] ).to eq_diff( :mismatch, "/b/c", ref: 3, can: 4 )
    end

    it "only has the first three diffs when passed a max_depth of 4" do
      diffs = invoke!(reference, candidate, max_depth: 4)
      expect( diffs.length ).to eq( 3 )
      expect( diffs[0] ).to eq_diff( :mismatch, "/a",     ref: 1, can: 2 )
      expect( diffs[1] ).to eq_diff( :mismatch, "/b/c",   ref: 3, can: 4 )
      expect( diffs[2] ).to eq_diff( :mismatch, "/b/d/e", ref: 5, can: 6 )
    end

    it "has all four diffs when passed a max_depth of 5" do
      diffs = invoke!(reference, candidate, max_depth: 5)
      expect( diffs.length ).to eq( 4 )
      expect( diffs[0] ).to eq_diff( :mismatch, "/a",       ref: 1, can: 2 )
      expect( diffs[1] ).to eq_diff( :mismatch, "/b/c",     ref: 3, can: 4 )
      expect( diffs[2] ).to eq_diff( :mismatch, "/b/d/e",   ref: 5, can: 6 )
      expect( diffs[3] ).to eq_diff( :mismatch, "/b/d/f/g", ref: 7, can: 8 )
    end
  end

  context "when given a complex data structure with more than one discrepancy" do
    let(:reference) {
      {
        id:    42,
        name:  "The Answer",
        words: %w[ what do you get when you multiply six by nine ],
        meta:  { foo: "spam", bar: "eggs", yak: "bacon" }
      }
    }
    let(:candidate) {
      {
        id:    42,
        name:  "Charlie",
        #      ^^^^^^^^^
        words: %w[ what do we get when I multiply six by nine dude ],
        #                  ^^          ^                      ^^^^
        meta:  { foo: "foo",              yak: "bacon" }
        #             ^^^^^  ^^^^^^^^^^^^
      }
    }

    it "has the correct number of mismatches" do
      diffs = invoke!(reference, candidate)
      expect( diffs.length ).to eq( 6 )

      expect( diffs["/name"]     ).to eq_diff( :mismatch, "/name",     ref: "The Answer", can: "Charlie" )
      expect( diffs["/words/3"]  ).to eq_diff( :mismatch, "/words/3",  ref: "you",        can: "we" )
      expect( diffs["/words/6"]  ).to eq_diff( :mismatch, "/words/6",  ref: "you",        can: "I" )
      expect( diffs["/words/11"] ).to eq_diff( :extra,    "/words/11", ref: nil,          can: "dude" )
      expect( diffs["/meta/foo"] ).to eq_diff( :mismatch, "/meta/foo", ref: "spam",       can: "foo" )
      expect( diffs["/meta/bar"] ).to eq_diff( :missing,  "/meta/bar", ref: "eggs",       can: nil )
    end

    it "can be told to stop after N mismatches" do
      diffs = invoke!(reference, candidate, max_diffs: 3)
      expect( diffs.length ).to eq( 3 )

      expect( diffs["/name"]     ).to eq_diff( :mismatch, "/name",     ref: "The Answer", can: "Charlie" )
      expect( diffs["/words/3"]  ).to eq_diff( :mismatch, "/words/3",  ref: "you",        can: "we" )
      expect( diffs["/words/6"]  ).to eq_diff( :mismatch, "/words/6",  ref: "you",        can: "I" )
    end

    it "can be told to record ONLY diffs matching ONE specified path" do
      diffs = invoke!(reference, candidate, select_paths: ["/words"])
      expect( diffs.length ).to eq( 3 )

      expect( diffs["/words/3"]  ).to eq_diff( :mismatch, "/words/3",  ref: "you", can: "we" )
      expect( diffs["/words/6"]  ).to eq_diff( :mismatch, "/words/6",  ref: "you", can: "I" )
      expect( diffs["/words/11"] ).to eq_diff( :extra,    "/words/11", ref: nil,   can: "dude" )
    end

    it "can be told to record ONLY diffs matching TWO specified paths" do
      diffs = invoke!(reference, candidate, select_paths: ["/name", "/words"])
      expect( diffs.length ).to eq( 4 )

      expect( diffs["/name"]     ).to eq_diff( :mismatch, "/name",     ref: "The Answer", can: "Charlie" )
      expect( diffs["/words/3"]  ).to eq_diff( :mismatch, "/words/3",  ref: "you",        can: "we" )
      expect( diffs["/words/6"]  ).to eq_diff( :mismatch, "/words/6",  ref: "you",        can: "I" )
      expect( diffs["/words/11"] ).to eq_diff( :extra,    "/words/11", ref: nil,          can: "dude" )
    end

    it "can be told to NOT record diffs matching ONE specified path" do
      diffs = invoke!(reference, candidate, reject_paths: ["/words"])
      expect( diffs.length ).to eq( 3 )

      expect( diffs["/name"]     ).to eq_diff( :mismatch, "/name",     ref: "The Answer", can: "Charlie" )
      expect( diffs["/meta/foo"] ).to eq_diff( :mismatch, "/meta/foo", ref: "spam",       can: "foo" )
      expect( diffs["/meta/bar"] ).to eq_diff( :missing,  "/meta/bar", ref: "eggs",       can: nil )
    end

    it "can be told to NOT record diffs matching TWO specified paths" do
      diffs = invoke!(reference, candidate, reject_paths: ["/name", "/words"])
      expect( diffs.length ).to eq( 2 )

      expect( diffs["/meta/foo"] ).to eq_diff( :mismatch, "/meta/foo", ref: "spam", can: "foo" )
      expect( diffs["/meta/bar"] ).to eq_diff( :missing,  "/meta/bar", ref: "eggs", can: nil )
    end

    specify "attempting to invoke with both :select_paths and :reject_paths asplodes" do
      expect { invoke!(reference, candidate, select_paths: ["/foo"], reject_paths: ["/bar"]) }.to \
        raise_error( CheckPlease::InvalidFlag )
    end
  end
end
