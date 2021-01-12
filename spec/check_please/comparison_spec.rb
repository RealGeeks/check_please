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
