require_relative "shared_contexts"

RSpec.describe CheckPlease::Comparison do
  def invoke!(ref, can)
    CheckPlease::Comparison.perform(ref, can)
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

  context "when given a complex data structure with more than one discrepancy" do
    include_context "complex pair"
    let(:reference) { complex_reference }
    let(:candidate) { complex_candidate }

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
  end
end
