RSpec.describe CheckPlease::Comparison do
  def invoke!(ref, can, flags = {})
    CheckPlease::Comparison.perform(ref, can, flags)
  end

  context "when given two integers" do
    let(:reference) { 42 }
    let(:candidate) { 43 }

    it "has one diff for the top-level mismatch" do
      diffs = invoke!(reference, candidate)
      expect( diffs.length ).to eq( 1 )
      expect( diffs[0] ).to eq_diff( :mismatch, "/", ref: 42, can: 43 )
    end
  end

  context "when given a String and a Symbol" do
    let(:reference) { "foo" }
    let(:candidate) { :foo }

    specify "by default, it has one diff for the mismatch" do
      diffs = invoke!(reference, candidate)
      expect( diffs.length ).to eq( 1 )
      expect( diffs[0] ).to eq_diff( :mismatch, "/", ref: "foo", can: :foo )
    end

    specify "it has no diffs when the `indifferent_values` flag is true" do
      diffs = invoke!(reference, candidate, indifferent_values: true)
      expect( diffs ).to be_empty
    end
  end

  context "when given a Symbol and a String" do
    let(:reference) { :foo }
    let(:candidate) { "foo" }

    specify "by default, it has one diff for the mismatch" do
      diffs = invoke!(reference, candidate)
      expect( diffs.length ).to eq( 1 )
      expect( diffs[0] ).to eq_diff( :mismatch, "/", ref: :foo, can: "foo" )
    end

    specify "it has no diffs when the `indifferent_values` flag is true" do
      diffs = invoke!(reference, candidate, indifferent_values: true)
      expect( diffs ).to be_empty
    end
  end

  context "when given two arrays of scalars" do
    context "same length, same order, different elements" do
      let(:reference) { [ 1, 2, 3 ] }
      let(:candidate) { [ 1, 2, 5 ] }

      it "has one diff for the second-level mismatch" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :mismatch, "/3", ref: 3, can: 5 )
      end
    end

    context "same length, different order, different elements" do
      let(:reference) { [ 1, 2, 3 ] }
      let(:candidate) { [ 5, 1, 2 ] }

      it "has three diffs" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 3 )
        expect( diffs[0] ).to eq_diff( :mismatch, "/1", ref: 1, can: 5 )
        expect( diffs[1] ).to eq_diff( :mismatch, "/2", ref: 2, can: 1 )
        expect( diffs[2] ).to eq_diff( :mismatch, "/3", ref: 3, can: 2 )
      end

      specify "it has two diffs (one missing, one extra) when the `match_by_value` list contains a matching path" do
        diffs = invoke!(reference, candidate, match_by_value: [ "/" ])
        expect( diffs.length ).to eq( 2 )
        expect( diffs[0] ).to eq_diff( :missing, "/3", ref: 3,   can: nil )
        expect( diffs[1] ).to eq_diff( :extra,   "/1", ref: nil, can: 5 )
      end
    end

    context "same order, reference longer than candidate" do
      let(:reference) { [ 1, 2, 3 ] }
      let(:candidate) { [ 1, 2 ] }

      it "has one diff for the missing element" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :missing, "/3", ref: 3, can: nil )
      end
    end

    context "different order, reference longer than candidate, extra reference value is a duplicate" do
      let(:reference) { [ 1, 2, 1 ] }
      let(:candidate) { [ 2, 1 ] }

      it "has three diffs" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 3 )
        expect( diffs[0] ).to eq_diff( :mismatch, "/1", ref: 1, can: 2 )
        expect( diffs[1] ).to eq_diff( :mismatch, "/2", ref: 2, can: 1 )
        expect( diffs[2] ).to eq_diff( :missing,  "/3", ref: 1, can: nil )
      end

      specify "it has one diff for the missing element when the `match_by_value` list contains a matching path" do
        diffs = invoke!(reference, candidate, match_by_value: [ "/" ])
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :missing, "/3", ref: 1, can: nil )
      end
    end

    context "different order, reference longer than candidate" do
      let(:reference) { [ 1, 2, 3 ] }
      let(:candidate) { [ 2, 1 ] }

      it "has three diffs" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 3 )
        expect( diffs[0] ).to eq_diff( :mismatch, "/1", ref: 1, can: 2 )
        expect( diffs[1] ).to eq_diff( :mismatch, "/2", ref: 2, can: 1 )
        expect( diffs[2] ).to eq_diff( :missing,  "/3", ref: 3, can: nil )
      end

      specify "it has one diff for the missing element when the `match_by_value` list contains a matching path" do
        diffs = invoke!(reference, candidate, match_by_value: [ "/" ])
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :missing, "/3", ref: 3, can: nil )
      end
    end

    context "same order, reference shorter than candidate" do
      let(:reference) { [ 1, 2 ] }
      let(:candidate) { [ 1, 2, 3 ] }

      it "has one diff for the extra element" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :extra, "/3", ref: nil, can: 3 )
      end
    end

    context "different order, reference shorter than candidate, extra candidate value is a duplicate" do
      let(:reference) { [ 1, 2 ] }
      let(:candidate) { [ 2, 1, 1 ] }

      it "has three diffs" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 3 )
        expect( diffs[0] ).to eq_diff( :mismatch, "/1", ref: 1,   can: 2 )
        expect( diffs[1] ).to eq_diff( :mismatch, "/2", ref: 2,   can: 1 )
        expect( diffs[2] ).to eq_diff( :extra,    "/3", ref: nil, can: 1 )
      end

      it "has one diff for the extra element when the `match_by_value` list contains a matching path" do
        diffs = invoke!(reference, candidate, match_by_value: [ "/" ])
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :extra, "/3", ref: nil, can: 1 )
      end
    end

    context "different order, reference shorter than candidate" do
      let(:reference) { [ 1, 2 ] }
      let(:candidate) { [ 2, 1, 3 ] }

      it "has three diffs" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 3 )
        expect( diffs[0] ).to eq_diff( :mismatch, "/1", ref: 1,   can: 2 )
        expect( diffs[1] ).to eq_diff( :mismatch, "/2", ref: 2,   can: 1 )
        expect( diffs[2] ).to eq_diff( :extra,    "/3", ref: nil, can: 3 )
      end

      it "has one diff for the extra element when the `match_by_value` list contains a matching path" do
        diffs = invoke!(reference, candidate, match_by_value: [ "/" ])
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :extra, "/3", ref: nil, can: 3 )
      end
    end

    context "same elements, different order" do
      let(:reference) { [ 1, 2, 3 ] }
      let(:candidate) { [ 3, 2, 1 ] }

      it "has a diff for each mismatch" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 2 )
        expect( diffs[0] ).to eq_diff( :mismatch, "/1", ref: 1, can: 3 )
        expect( diffs[1] ).to eq_diff( :mismatch, "/3", ref: 3, can: 1 )
      end
    end
  end

  context "when given two hashes of integers" do
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

  context "when given a reference hash with String keys and a candidate hash with Symbol keys" do
    context "same length, one key name mismatch" do
      let(:reference) { { "foo" => 1, "bar" => 2, "yak" => 3 } }
      let(:candidate) { { :foo  => 1, :bar  => 2, :quux => 3 } }

      context "by default" do
        it "has six diffs" do
          diffs = invoke!(reference, candidate)
          expect( diffs.length ).to eq( 6 )

          expect( diffs[0] ).to eq_diff( :missing, "/foo",  ref: 1,   can: nil )
          expect( diffs[1] ).to eq_diff( :missing, "/bar",  ref: 2,   can: nil )
          expect( diffs[2] ).to eq_diff( :missing, "/yak",  ref: 3,   can: nil )
          expect( diffs[3] ).to eq_diff( :extra,   "/foo",  ref: nil, can: 1 )
          expect( diffs[4] ).to eq_diff( :extra,   "/bar",  ref: nil, can: 2 )
          expect( diffs[5] ).to eq_diff( :extra,   "/quux", ref: nil, can: 3 )
        end
      end

      context "when the indifferent_keys flag is true" do
        it "has two diffs: one missing, one extra" do
          diffs = invoke!(reference, candidate, indifferent_keys: true)
          expect( diffs.length ).to eq( 2 )
          expect( diffs[0] ).to eq_diff( :missing, "/yak",  ref: 3,   can: nil )
          expect( diffs[1] ).to eq_diff( :extra,   "/quux", ref: nil, can: 3 )
        end
      end
    end
  end

  context "when given a reference hash with Symbol keys and a candidate hash with String keys" do
    context "same length, one key name mismatch" do
      let(:reference) { { :foo  => 1, :bar  => 2, :yak   => 3 } }
      let(:candidate) { { "foo" => 1, "bar" => 2, "quux" => 3 } }

      context "by default" do
        it "has six diffs" do
          diffs = invoke!(reference, candidate)
          expect( diffs.length ).to eq( 6 )

          expect( diffs[0] ).to eq_diff( :missing, "/foo",  ref: 1,   can: nil )
          expect( diffs[1] ).to eq_diff( :missing, "/bar",  ref: 2,   can: nil )
          expect( diffs[2] ).to eq_diff( :missing, "/yak",  ref: 3,   can: nil )
          expect( diffs[3] ).to eq_diff( :extra,   "/foo",  ref: nil, can: 1 )
          expect( diffs[4] ).to eq_diff( :extra,   "/bar",  ref: nil, can: 2 )
          expect( diffs[5] ).to eq_diff( :extra,   "/quux", ref: nil, can: 3 )
        end
      end

      context "when the indifferent_keys flag is true" do
        it "has two diffs: one missing, one extra" do
          diffs = invoke!(reference, candidate, indifferent_keys: true)
          expect( diffs.length ).to eq( 2 )
          expect( diffs[0] ).to eq_diff( :missing, "/yak",  ref: 3,   can: nil )
          expect( diffs[1] ).to eq_diff( :extra,   "/quux", ref: nil, can: 3 )
        end
      end
    end
  end

  context "when given two hashes of arrays" do
    context "top-level hash keys differ" do
      let(:reference) { { foo: [ 1, 2, 3 ], bar: [ 4, 5, 6 ] } }
      let(:candidate) { { foo: [ 1, 2, 3 ], yak: [ 7, 8, 9 ] } }

      it "has two diffs: one missing, one extra" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 2 )
        expect( diffs["/bar"] ).to eq_diff( :missing, "/bar", ref: [4,5,6], can: nil )
        expect( diffs["/yak"] ).to eq_diff( :extra,   "/yak", ref: nil,     can: [7,8,9] )
      end
    end

    context "top-level hash keys differ but the arrays are the same" do
      let(:reference) { { foo: [ 1, 2, 3 ], bar: [ 4, 5, 6 ] } }
      let(:candidate) { { foo: [ 1, 2, 3 ], yak: [ 4, 5, 6 ] } }

      it "has two diffs: one missing, one extra" do
        diffs = invoke!(reference, candidate)
        expect( diffs.length ).to eq( 2 )
        expect( diffs["/bar"] ).to eq_diff( :missing, "/bar", ref: [4,5,6], can: nil )
        expect( diffs["/yak"] ).to eq_diff( :extra,   "/yak", ref: nil,     can: [4,5,6] )
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
    it "raises an exception when the `match_by_value` list contains a matching path" do
      reference = [ { foo: 1 } ]

      candidate = [ { foo: 1 } ]
      expect { invoke!(reference, candidate, match_by_value: [ "/" ]) }.to \
        raise_error( CheckPlease::BehaviorUndefined )
    end

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
      specify "comparing [A,B] with [B,A] with no match_by_key expressions complains a lot" do
        ref = [ a, b ]
        can = [ b, a ]
        diffs = invoke!( ref, can, match_by_key: [] ) # note empty list
        expect( diffs.length ).to eq( 4 )
        expect( diffs[0] ).to eq_diff( :mismatch, "/1/id",  ref: a["id"],  can: b["id"] )
        expect( diffs[1] ).to eq_diff( :mismatch, "/1/foo", ref: a["foo"], can: b["foo"] )
        expect( diffs[2] ).to eq_diff( :mismatch, "/2/id",  ref: b["id"],  can: a["id"] )
        expect( diffs[3] ).to eq_diff( :mismatch, "/2/foo", ref: b["foo"], can: a["foo"] )
        #                                                        ^              ^
      end

      specify "comparing [A,B] with [B,A] correctly matches up A and B using the :id value, resulting in zero diffs" do
        ref = [ a, b ]
        can = [ b, a ]
        diffs = invoke!( ref, can, match_by_key: [ "/:id" ] )
        expect( diffs.length ).to eq( 0 )
      end

      specify "comparing [A,B] with [A] complains that B is missing" do
        ref = [ a, b ]
        can = [ a ]
        diffs = invoke!( ref, can, match_by_key: [ "/:id" ] )
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :missing, "/id=#{b[b_key_name]}", ref: b, can: nil )
      end

      specify "comparing [A,B] with [B] complains that A is missing" do
        ref = [ a, b ]
        can = [ b ]
        diffs = invoke!( ref, can, match_by_key: [ "/:id" ] )
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :missing, "/id=#{a[a_key_name]}", ref: a, can: nil )
      end

      specify "comparing [A] with [A,B] complains that B is extra" do
        ref = [ a ]
        can = [ a, b ]
        diffs = invoke!( ref, can, match_by_key: [ "/:id" ] )
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :extra, "/id=#{b[b_key_name]}", ref: nil, can: b )
      end

      specify "comparing [B] with [A,B] complains that B is extra" do
        ref = [ b ]
        can = [ a, b ]
        diffs = invoke!( ref, can, match_by_key: [ "/:id" ] )
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :extra, "/id=#{a[a_key_name]}", ref: nil, can: a )
      end

      specify "comparing two lists where the top-level elements can be matched by key but have different child values... works (explicit keys for both levels)" do
        ref = [ { "id" => 1, "deeply" => { "nested" => [ a, b ] } } ]
        can = [ { "id" => 1, "deeply" => { "nested" => [ c, a ] } } ]

        diffs = invoke!( ref, can, match_by_key: [ "/:id", "/:id/deeply/nested/:id" ] )
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :mismatch, "/id=1/deeply/nested/id=2/foo", ref: "bat", can: "yak" )
      end

      specify "comparing two lists where the top-level elements can be matched by key but have different child values... works (implicit key for top level)" do
        ref = [ { "id" => 1, "deeply" => { "nested" => [ a, b ] } } ]
        can = [ { "id" => 1, "deeply" => { "nested" => [ c, a ] } } ]

        diffs = invoke!( ref, can, match_by_key: [         "/:id/deeply/nested/:id" ] )
        #                                          ^^^^^^^ no "/:id" here
        expect( diffs.length ).to eq( 1 )
        expect( diffs[0] ).to eq_diff( :mismatch, "/id=1/deeply/nested/id=2/foo", ref: "bat", can: "yak" )
      end

      specify "comparing [A,B] with [B,A] raises NoSuchKeyError if given a bogus key expression" do
        ref = [ a, b ]
        can = [ b, a ]
        expect { invoke!( ref, can, match_by_key: [ "/:identifier" ] ) }.to \
          raise_error(CheckPlease::NoSuchKeyError, /The reference hash at position 0 has no "identifier" key/)
      end

      specify "comparing [A,A] with [A] raises DuplicateKeyError" do
        ref = [ a, a ]
        can = [ a ]
        expect { invoke!( ref, can, match_by_key: [ "/:id" ] ) }.to \
          raise_error(CheckPlease::DuplicateKeyError, /Duplicate reference element found/)
      end

      specify "comparing [A,A] with [A,A] raises DuplicateKeyError" do
        ref = [ a, a ]
        can = [ a, a ]
        expect { invoke!( ref, can, match_by_key: [ "/:id" ] ) }.to \
          raise_error(CheckPlease::DuplicateKeyError, /Duplicate reference element found/)
      end

      specify "comparing [A] with [A,A] raises DuplicateKeyError" do
        ref = [ a ]
        can = [ a, a ]
        expect { invoke!( ref, can, match_by_key: [ "/:id" ] ) }.to \
          raise_error(CheckPlease::DuplicateKeyError, /Duplicate candidate element found/)
      end

      specify "comparing [A] with [A,A,B] raises DuplicateKeyError" do
        ref = [ a ]
        can = [ a, a, b ]
        expect { invoke!( ref, can, match_by_key: [ "/:id" ] ) }.to \
          raise_error(CheckPlease::DuplicateKeyError, /Duplicate candidate element found/)
      end

      specify "comparing [42] with [A] raises TypeMismatchError" do
        ref = [ 42 ]
        can = [ a ]
        expect { invoke!( ref, can, match_by_key: [ "/:id" ] ) }.to \
          raise_error(CheckPlease::TypeMismatchError, /The element at position \d+ in the reference array is not a hash/)
      end

      specify "comparing [A] with [42] raises TypeMismatchError" do
        ref = [ a ]
        can = [ 42 ]
        expect { invoke!( ref, can, match_by_key: [ "/:id" ] ) }.to \
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

    it "can be told to NOT record diffs matching a wildcard path" do
      diffs = invoke!(reference, candidate, reject_paths: ["/meta/*"])
      expect( diffs.length ).to eq( 4 )

      expect( diffs["/name"]     ).to eq_diff( :mismatch, "/name",     ref: "The Answer", can: "Charlie" )
      expect( diffs["/words/3"]  ).to eq_diff( :mismatch, "/words/3",  ref: "you",        can: "we" )
      expect( diffs["/words/6"]  ).to eq_diff( :mismatch, "/words/6",  ref: "you",        can: "I" )
      expect( diffs["/words/11"] ).to eq_diff( :extra,    "/words/11", ref: nil,          can: "dude" )
    end

    it "can be told to NOT record diffs matching a wildcard path, part 2" do
      reference = { posts: [ { id: 1, name: "Alice" } ] }
      candidate = { posts: [ { id: 2, name: "Bob" } ] }
      diffs = invoke!(reference, candidate, reject_paths: ["/posts/*/name"])
      expect( diffs.length ).to eq( 1 )

      expect( diffs[0] ).to eq_diff( :mismatch, "/posts/1/id", ref: 1, can: 2)
    end

    it "can be told to NOT record diffs matching a wildcard path, part 3" do
      reference = { posts: [ { id: 1, ads: [ { time: "soon" } ] } ] }
      candidate = { posts: [ { id: 2, ads: [ { time: "late" } ] } ] }
      diffs = invoke!(reference, candidate, reject_paths: ["/posts/*/ads/*/time"])
      expect( diffs.length ).to eq( 1 )

      expect( diffs[0] ).to eq_diff( :mismatch, "/posts/1/id", ref: 1, can: 2)
    end

    specify "attempting to invoke with both :select_paths and :reject_paths asplodes" do
      expect { invoke!(reference, candidate, select_paths: ["/foo"], reject_paths: ["/bar"]) }.to \
        raise_error( CheckPlease::InvalidFlag )
    end
  end

  specify "match_by_key and match_by_value play well together" do
    a  = { "id" => 1, "list" => [ 1, 2, 3 ] }
    b1 = { "id" => 2, "list" => [ 4, 5, 6 ] }
    b2 = { "id" => 2, "list" => [ 4, 5, 1 ] } # degrees Fahrenheit

    reference = [ a,  b1 ]
    candidate = [ b2, a ]
    diffs = invoke!( reference, candidate, match_by_key: [ "/:id" ], match_by_value: [ "/:id/list" ] )
    expect( diffs.length ).to eq( 2 )

    expect( diffs[0] ).to eq_diff( :missing, "/id=2/list/3", ref: 6,   can: nil )
    expect( diffs[1] ).to eq_diff( :extra,   "/id=2/list/3", ref: nil, can: 1 )
  end

  specify "match_by_value and wildcards play well together" do
    reference = { "data" => { "letters" => %w[ a b c ], "numbers" => [ 1, 2, 3 ] } }
    candidate = { "data" => { "letters" => %w[ b a d ], "numbers" => [ 3, 2, 5 ] } }

    diffs = invoke!( reference, candidate, match_by_value: [ "/data/*" ] )
    expect( diffs.length ).to eq( 4 )

    expect( diffs[0] ).to eq_diff( :missing, "/data/letters/3", ref: "c", can: nil )
    expect( diffs[1] ).to eq_diff( :extra,   "/data/letters/3", ref: nil, can: "d" )
    expect( diffs[2] ).to eq_diff( :missing, "/data/numbers/1", ref: 1,   can: nil )
    expect( diffs[3] ).to eq_diff( :extra,   "/data/numbers/3", ref: nil, can: 5 )
  end

  describe "the normalize_values flag" do
    it "transforms values that match a given path" do
      iso8601 = "2021-03-15T12:34:56+00:00"
      rfc2822 = "Mon, 15 Mar 2021 12:34:56 +0000"

      reference = { id: 42, time: iso8601, number: 123 }
      candidate = { id: 42, time: rfc2822, number: "123" }

      # Make sure the diffs actually have what I expect
      diffs = invoke!( reference, candidate )
      expect( diffs.length ).to eq( 2 )
      expect( diffs[0] ).to eq_diff( :mismatch, "/time",   ref: iso8601, can: rfc2822 )
      expect( diffs[1] ).to eq_diff( :mismatch, "/number", ref: 123,     can: "123" )

      require 'time'
      # now actually test with normalize_values
      diffs = invoke!( reference, candidate, normalize_values: {
        "/time" => ->(v) { Time.parse(v) },
      })
      expect( diffs.length ).to eq( 1 )
      expect( diffs[0] ).to eq_diff( :mismatch, "/number", ref: 123,     can: "123" )

      diffs = invoke!( reference, candidate, normalize_values: {
        "/number" => ->(v) { v.to_i },
      })
      expect( diffs.length ).to eq( 1 )
      expect( diffs[0] ).to eq_diff( :mismatch, "/time",   ref: iso8601, can: rfc2822 )

      diffs = invoke!( reference, candidate, normalize_values: {
        "/time"   => ->(v) { Time.parse(v) },
        "/number" => ->(v) { v.to_i },
      })
      expect( diffs.length ).to eq( 0 )
    end

    it "reports the un-transformed value on transformed diffs" do
      reference = { id: 42, number: 123 }
      candidate = { id: 42, number: "234" }

      # Make sure the diffs actually have what I expect
      diffs = invoke!( reference, candidate )
      expect( diffs.length ).to eq( 1 )
      expect( diffs[0] ).to eq_diff( :mismatch, "/number", ref: 123, can: "234" )

      diffs = invoke!( reference, candidate, normalize_values: {
        "/number" => ->(v) { v.to_i },
      })
      expect( diffs.length ).to eq( 1 )
      expect( diffs[0] ).to eq_diff( :mismatch, "/number", ref: 123, can: "234" )
    end

    context "when comparing two lists, one of strings and the other of symbols" do
      let(:list_of_strings) { { list: %w[ foo bar yak ] } }
      let(:list_of_symbols) { { list: %i[ foo bar yak ] } }

      def invoke_with!(paths_to_procs = {})
        invoke!( list_of_strings, list_of_symbols, normalize_values: paths_to_procs )
      end

      before do
        diffs = invoke!( list_of_strings, list_of_symbols )
        expect( diffs.length ).to eq( 3 )
        expect( diffs[0] ).to eq_diff( :mismatch, "/list/1", ref: "foo", can: :foo )
        expect( diffs[1] ).to eq_diff( :mismatch, "/list/2", ref: "bar", can: :bar )
        expect( diffs[2] ).to eq_diff( :mismatch, "/list/3", ref: "yak", can: :yak )
      end

      it "works with path expressions" do
        diffs = invoke_with!(
          "/list/*" => ->(v) { v.to_s },
        )
        expect( diffs.length ).to eq( 0 )
      end

      it "works with symbol values instead of procs" do
        diffs = invoke_with!(
          "/list/*" => :to_s,
        )
        expect( diffs.length ).to eq( 0 )
      end

      it "works with string values instead of procs" do
        diffs = invoke_with!(
          "/list/*" => "to_s",
        )
        expect( diffs.length ).to eq( 0 )
      end
    end

  end

end
