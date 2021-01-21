RSpec.describe CheckPlease::Flags do
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
    it "defaults to false" do
      flags = flagify#####
      expect( flags.fail_fast ).to be false
    end

    it "can be set to true at initialization time" do
      flags = flagify( fail_fast: true )
      expect( flags.fail_fast ).to be true
    end

    def self.it_coerces(value, to:)
      it "coerces #{value.inspect} to #{to.inspect}" do
        flags = flagify( fail_fast: value )
        expect( flags.fail_fast ).to be to
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

    it "contains path/key expression" do
      flags = flagify()
      flags.match_by_key = "/foo[id,name]"
      expect( flags.match_by_key ).to eq( [ "/foo[id,name]" ] )
    end
  end
end
