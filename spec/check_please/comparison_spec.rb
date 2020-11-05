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

      diffs[0].tap do |diff|
        expect( diff.type      ).to eq( :mismatch )
        expect( diff.path      ).to eq( "/" )
        expect( diff.reference ).to eq( 42 )
        expect( diff.candidate ).to eq( 43 )
      end
    end
  end

  context "when given two arrays of scalars" do
    context "same length, different elements" do
      let(:reference) { [ 1, 2, 3 ] }
      let(:candidate) { [ 1, 2, 5 ] }

      it "has one diff for the second-level mismatch" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 1 )

        diffs[0].tap do |diff|
          expect( diff.path      ).to eq( "/3" )
          expect( diff.reference ).to eq( 3 )
          expect( diff.candidate ).to eq( 5 )
        end
      end
    end

    context "reference longer than candidate" do
      let(:reference) { [ 1, 2, 3 ] }
      let(:candidate) { [ 1, 2 ] }

      it "has one diff for the missing element" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 1 )

        diffs[0].tap do |diff|
          expect( diff.type      ).to eq( :missing )
          expect( diff.path      ).to eq( "/3" )
          expect( diff.reference ).to eq( 3 )
          expect( diff.candidate ).to eq( nil )
        end
      end
    end

    context "reference shorter than candidate" do
      let(:reference) { [ 1, 2 ] }
      let(:candidate) { [ 1, 2, 3 ] }

      it "has one diff for the extra element" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 1 )

        diffs[0].tap do |diff|
          expect( diff.type      ).to eq( :extra )
          expect( diff.path      ).to eq( "/3" )
          expect( diff.reference ).to eq( nil )
          expect( diff.candidate ).to eq( 3 )
        end
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

        diffs["/yak"].tap do |diff|
          expect( diff.type      ).to eq( :missing )
          expect( diff.path      ).to eq( "/yak" )
          expect( diff.reference ).to eq( 3 )
          expect( diff.candidate ).to eq( nil )
        end

        diffs["/quux"].tap do |diff|
          expect( diff.type      ).to eq( :extra )
          expect( diff.path      ).to eq( "/quux" )
          expect( diff.reference ).to eq( nil )
          expect( diff.candidate ).to eq( 3 )
        end
      end
    end

    context "same length, same keys, one value mismatch" do
      let(:reference) { { foo: 1, bar: 2, yak: 3 } }
      let(:candidate) { { foo: 1, bar: 2, yak: 5 } }

      it "has one diff for the mismatch" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 1 )

        diffs[0].tap do |diff|
          expect( diff.type      ).to eq( :mismatch )
          expect( diff.path      ).to eq( "/yak" )
          expect( diff.reference ).to eq( 3 )
          expect( diff.candidate ).to eq( 5 )
        end
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

        diffs["/bar"].tap do |diff|
          expect( diff.type      ).to eq( :missing )
          expect( diff.path      ).to eq( "/bar" )
          expect( diff.reference ).to eq( [2,3,4] )
          expect( diff.candidate ).to eq( nil )
        end

        diffs["/yak"].tap do |diff|
          expect( diff.type      ).to eq( :extra )
          expect( diff.path      ).to eq( "/yak" )
          expect( diff.reference ).to eq( nil )
          expect( diff.candidate ).to eq( [2,3,5] )
        end
      end
    end

    context "nested array elements differ" do
      let(:reference) { { foo: [ 1, 2, 3 ], bar: [ 2, 3, 4 ] } }
      let(:candidate) { { foo: [ 1, 2, 3 ], bar: [ 2, 3, 5 ] } }

      it "has one diff for the mismatch in the nested array elements" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 1 )

        diffs[0].tap do |diff|
          expect( diff.type      ).to eq( :mismatch )
          expect( diff.path      ).to eq( "/bar/3" )
          expect( diff.reference ).to eq( 4 )
          expect( diff.candidate ).to eq( 5 )
        end
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

        diffs["/1/yak"].tap do |diff|
          expect( diff.type      ).to eq( :missing )
          expect( diff.path      ).to eq( "/1/yak" )
          expect( diff.reference ).to eq( 3 )
          expect( diff.candidate ).to eq( nil )
        end

        diffs["/1/quux"].tap do |diff|
          expect( diff.type      ).to eq( :extra )
          expect( diff.path      ).to eq( "/1/quux" )
          expect( diff.reference ).to eq( nil )
          expect( diff.candidate ).to eq( 3 )
        end
      end
    end

    context "same length, nested hash keys same, one value mismatch" do
      let(:reference) { [ { foo: 1, bar: 2, yak: 3 } ] }
      let(:candidate) { [ { foo: 1, bar: 2, yak: 5 } ] }

      it "has one diff for the mismatch" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 1 )

        diffs[0].tap do |diff|
          expect( diff.type      ).to eq( :mismatch )
          expect( diff.path      ).to eq( "/1/yak" )
          expect( diff.reference ).to eq( 3 )
          expect( diff.candidate ).to eq( 5 )
        end
      end
    end

    context "reference longer than candidate" do
      let(:reference) { [ { foo: 1 }, { bar: 2 } ] }
      let(:candidate) { [ { foo: 1 } ] }

      it "has one diff for the missing hash" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 1 )

        diffs[0].tap do |diff|
          expect( diff.type      ).to eq( :missing )
          expect( diff.path      ).to eq( "/2" )
          expect( diff.reference ).to eq( { bar: 2 } )
          expect( diff.candidate ).to eq( nil )
        end
      end
    end

    context "candidate longer than reference" do
      let(:reference) { [ { foo: 1 } ] }
      let(:candidate) { [ { foo: 1 }, { bar: 2 } ] }

      it "has one diff for the extra hash" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 1 )

        diffs[0].tap do |diff|
          expect( diff.type      ).to eq( :extra )
          expect( diff.path      ).to eq( "/2" )
          expect( diff.reference ).to eq( nil )
          expect( diff.candidate ).to eq( { bar: 2 } )
        end
      end
    end
  end

  context "when given an Array :reference and an Integer :candidate" do
    let(:reference) { [ 42 ] }
    let(:candidate) { 42 }

    it "has one diff for the top-level mismatch" do
      diffs = invoke!(reference, candidate)
      expect( diffs.length ).to eq( 1 )

      diffs[0].tap do |diff|
        expect( diff.type      ).to eq( :type_mismatch )
        expect( diff.path      ).to eq( "/" )
        expect( diff.reference ).to eq( [42] )
        expect( diff.candidate ).to eq( 42 )
      end
    end
  end

  context "when given an Integer :reference and an Array :candidate" do
    let(:reference) { 42 }
    let(:candidate) { [ 42 ] }

    it "has one diff for the top-level mismatch" do
      diffs = invoke!(reference, candidate)
      expect( diffs.length ).to eq( 1 )

      diffs[0].tap do |diff|
        expect( diff.type      ).to eq( :type_mismatch )
        expect( diff.path      ).to eq( "/" )
        expect( diff.reference ).to eq( 42 )
        expect( diff.candidate ).to eq( [42] )
      end
    end
  end

  context "when given a complex data structure with more than one discrepancy" do
    include_context "complex pair"
    let(:reference) { complex_reference }
    let(:candidate) { complex_candidate }

    it "has the correct number of mismatches" do
      diffs = invoke!(reference, candidate)
      expect( diffs.length ).to eq( 6 )

      diffs["/name"].tap do |diff|
        expect( diff.type      ).to eq( :mismatch )
        expect( diff.path      ).to eq( "/name" )
        expect( diff.reference ).to eq( "The Answer" )
        expect( diff.candidate ).to eq( "Charlie" )
      end

      diffs["/words/3"].tap do |diff|
        expect( diff.type      ).to eq( :mismatch )
        expect( diff.path      ).to eq( "/words/3" )
        expect( diff.reference ).to eq( "you" )
        expect( diff.candidate ).to eq( "we" )
      end

      diffs["/words/6"].tap do |diff|
        expect( diff.type      ).to eq( :mismatch )
        expect( diff.path      ).to eq( "/words/6" )
        expect( diff.reference ).to eq( "you" )
        expect( diff.candidate ).to eq( "I" )
      end

      diffs["/words/11"].tap do |diff|
        expect( diff.type      ).to eq( :extra )
        expect( diff.path      ).to eq( "/words/11" )
        expect( diff.reference ).to eq( nil )
        expect( diff.candidate ).to eq( "dude" )
      end

      diffs["/meta/foo"].tap do |diff|
        expect( diff.type      ).to eq( :mismatch )
        expect( diff.path      ).to eq( "/meta/foo" )
        expect( diff.reference ).to eq( "spam" )
        expect( diff.candidate ).to eq( "foo" )
      end

      diffs["/meta/bar"].tap do |diff|
        expect( diff.type      ).to eq( :missing )
        expect( diff.path      ).to eq( "/meta/bar" )
        expect( diff.reference ).to eq( "eggs" )
        expect( diff.candidate ).to eq( nil )
      end
    end
  end

end

