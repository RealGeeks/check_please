RSpec.describe CheckPlease::Flags do
  shared_examples "a boolean flag" do
    it "defaults to false" do
      flags = flagify()
      expect( flags.send(flag_name) ).to be false
    end

    it "can be set to true at initialization time" do
      flags = flagify( flag_name => true )
      expect( flags.send(flag_name) ).to be true
    end

    def self.it_coerces(value, to:)
      expected_value = to
      it "coerces #{value.inspect} to #{to.inspect}" do
        flags = flagify( flag_name => value )

        actual = flags.send(flag_name) # <-- where the magic happens

        expect( actual ).to be( expected_value )
      end
    end

    it_coerces false, to: false
    it_coerces nil,   to: false

    it_coerces true,    to: true
    it_coerces 0,       to: true
    it_coerces 1,       to: true
    it_coerces "",      to: true
    it_coerces "yarp" , to: true
  end



  describe "#format" do
    it "defaults to CheckPlease::Printers::DEFAULT_FORMAT" do
      flags = flagify()
      expect( flags.format ).to eq( CheckPlease::Printers::DEFAULT_FORMAT )
    end

    it "can be set to :json at initialization time" do
      flags = flagify(format: :json)
      expect( flags.format ).to eq( :json )
    end

    it "can't be set to just anything" do
      expect { flagify(format: :wibble) }.to \
        raise_error( CheckPlease::InvalidFlag )
    end
  end

  describe "#max_diffs" do
    it "defaults to nil" do
      flags = flagify()
      expect( flags.max_diffs ).to be nil
    end

    it "can be set to an integer larger than zero at initialization time" do
      flags = flagify(max_diffs: 1)
      expect( flags.max_diffs ).to eq( 1 )
    end

    it "can't be set to zero" do
      expect { flagify(max_diffs: 0) }.to \
        raise_error( CheckPlease::InvalidFlag )
    end

    it "can't be set to a negative integer" do
      expect { flagify(max_diffs: -1) }.to \
        raise_error( CheckPlease::InvalidFlag )
    end

    it "coerces a string value to an integer" do
      flags = flagify(max_diffs: "42")
      expect( flags.max_diffs ).to eq( 42 )
    end
  end

  describe "#fail_fast" do
    it_behaves_like "a boolean flag" do
      let(:flag_name) { :fail_fast }
    end
  end

  describe "#max_depth" do
    it "defaults to nil" do
      flags = flagify()
      expect( flags.max_depth ).to be nil
    end

    it "can be set to an integer larger than zero at initialization time" do
      flags = flagify(max_depth: 1)
      expect( flags.max_depth ).to eq( 1 )
    end

    it "can't be set to zero" do
      expect { flagify(max_depth: 0) }.to \
        raise_error( CheckPlease::InvalidFlag )
    end

    it "can't be set to a negative integer" do
      expect { flagify(max_depth: -1) }.to \
        raise_error( CheckPlease::InvalidFlag )
    end

    it "coerces a string value to an integer" do
      flags = flagify(max_depth: "42")
      expect( flags.max_depth ).to eq( 42 )
    end
  end

  describe "select_paths" do
    it "defaults to an empty array" do
      flags = flagify()
      expect( flags.select_paths ).to eq( [] )
    end

    spec_body = ->(_example) {
      flags = flagify()
      flags.select_paths = "/foo"
      expect( flags.select_paths ).to eq( pathify([ "/foo" ]) )
      flags.select_paths = "/bar"
      expect( flags.select_paths ).to eq( pathify([ "/foo", "/bar" ]) )
    }

    specify "the setter is a little surprising: it [reifies and] appends any values it's given to a list", &spec_body
    specify "the list doesn't persist between instances", &spec_body
  end

  describe "reject_paths" do
    it "defaults to an empty array" do
      flags = flagify()
      expect( flags.reject_paths ).to eq( [] )
    end

    spec_body = ->(_example) {
      flags = flagify()
      flags.reject_paths = "/foo"
      expect( flags.reject_paths ).to eq( pathify([ "/foo" ]) )
      flags.reject_paths = "/bar"
      expect( flags.reject_paths ).to eq( pathify([ "/foo", "/bar" ]) )
    }

    specify "the setter is a little surprising: it [reifies and] appends any values it's given to a list", &spec_body
    specify "the list doesn't persist between instances", &spec_body
  end

  specify "select_paths and reject_paths can't both be set" do
    expect { flagify(select_paths: ["/foo"], reject_paths: ["/bar"]) }.to \
      raise_error( CheckPlease::InvalidFlag )
  end

  describe "match_by_key" do
    it "defaults to an empty array" do
      flags = flagify()
      expect( flags.match_by_key ).to eq( [] )
    end

    spec_body = ->(_example) {
      flags = flagify()
      flags.match_by_key = "/:id"
      expect( flags.match_by_key ).to eq( pathify([ "/:id" ]) )
      flags.match_by_key = "/foo/:id"
      expect( flags.match_by_key ).to eq( pathify([ "/:id", "/foo/:id" ]) )
      flags.match_by_key = "/bar/:id"
      expect( flags.match_by_key ).to eq( pathify([ "/:id", "/foo/:id", "/bar/:id" ]) )
    }

    specify "the setter is a little surprising: it [reifies and] appends any values it's given to a list", &spec_body
    specify "the list doesn't persist between instances", &spec_body
  end

  describe "#indifferent_keys" do
    it_behaves_like "a boolean flag" do
      let(:flag_name) { :indifferent_keys }
    end
  end

  describe "#indifferent_values" do
    it_behaves_like "a boolean flag" do
      let(:flag_name) { :indifferent_values }
    end
  end

end
