RSpec.describe CheckPlease::Flags do
  def flags(attrs = {})
    described_class.new(attrs)
  end

  describe "#format" do
    it "defaults to CheckPlease::Printers::DEFAULT_FORMAT" do
      expect( flags.format ).to eq( CheckPlease::Printers::DEFAULT_FORMAT )
    end

    it "can be set to :json at initialization time" do
      expect( flags(format: :json).format ).to eq( :json )
    end

    it "can't be set to just anything" do
      expect { flags(format: :wibble) }.to raise_error( ArgumentError )
    end
  end

  describe "#max_diffs" do
    it "defaults to nil" do
      expect( flags.max_diffs ).to be nil
    end

    it "can be set to an integer larger than zero at initialization time" do
      expect( flags(max_diffs: 1).max_diffs ).to eq( 1 )
    end

    it "can't be set to zero" do
      expect { flags(max_diffs: 0) }.to raise_error( ArgumentError )
    end

    it "can't be set to a negative integer" do
      expect { flags(max_diffs: -1) }.to raise_error( ArgumentError )
    end

    it "coerces a string value to an integer" do
      expect( flags(max_diffs: "42").max_diffs ).to eq( 42 )
    end
  end

  describe "#fail_fast" do
    it "defaults to false" do
      expect( flags.fail_fast ).to be false
    end

    it "can be set to true at initialization time" do
      expect( flags( fail_fast: true ).fail_fast ).to be true
    end

    it "coerces its value to a boolean" do
      expect( flags( fail_fast: false ).fail_fast ).to be false
      expect( flags( fail_fast: nil   ).fail_fast ).to be false

      expect( flags( fail_fast: true   ).fail_fast ).to be true
      expect( flags( fail_fast: 0      ).fail_fast ).to be true
      expect( flags( fail_fast: 1      ).fail_fast ).to be true
      expect( flags( fail_fast: ""     ).fail_fast ).to be true
      expect( flags( fail_fast: "yarp" ).fail_fast ).to be true
    end
  end

  describe "#max_depth" do
    it "defaults to nil" do
      expect( flags.max_depth ).to be nil
    end

    it "can be set to an integer larger than zero at initialization time" do
      expect( flags(max_depth: 1).max_depth ).to eq( 1 )
    end

    it "can't be set to zero" do
      expect { flags(max_depth: 0) }.to raise_error( ArgumentError )
    end

    it "can't be set to a negative integer" do
      expect { flags(max_depth: -1) }.to raise_error( ArgumentError )
    end

    it "coerces a string value to an integer" do
      expect( flags(max_depth: "42").max_depth ).to eq( 42 )
    end
  end

  describe "select_paths" do
    it "defaults to an empty array" do
      expect( flags.select_paths ).to eq( [] )
    end

    spec_body = ->(_example) {
      f = flags
      f.select_paths = "/foo"
      expect( f.select_paths ).to eq( [ "/foo" ] )
      f.select_paths = "/bar"
      expect( f.select_paths ).to eq( [ "/foo", "/bar" ] )
    }

    specify "the setter is a little surprising: it appends any values it's given to a list", &spec_body
    specify "the list doesn't persist between instances", &spec_body
  end

  describe "reject_paths" do
    it "defaults to an empty array" do
      expect( flags.reject_paths ).to eq( [] )
    end

    spec_body = ->(_example) {
      f = flags
      f.reject_paths = "/foo"
      expect( f.reject_paths ).to eq( [ "/foo" ] )
      f.reject_paths = "/bar"
      expect( f.reject_paths ).to eq( [ "/foo", "/bar" ] )
    }

    specify "the setter is a little surprising: it appends any values it's given to a list", &spec_body
    specify "the list doesn't persist between instances", &spec_body
  end
end
