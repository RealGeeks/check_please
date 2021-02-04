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

  shared_examples "a path list" do
    it "defaults to an empty array" do
      flags = flagify()
      expect( flags.send(flag_name) ).to eq( [] )
    end

    # Sorry, this got... super abstract when DRYed up :/

    spec_body = ->(_example) {
      flags = flagify()

      expected = []
      paths_to_add.each do |path_name|
        expected << path_name
        flags.send "#{flag_name}=", path_name
        actual = flags.send(flag_name)
        expect( actual ).to eq( pathify(expected) )
      end
    }

    specify "the setter is a little surprising: it [reifies and] appends any values it's given to a list", &spec_body
    specify "the list doesn't persist between instances", &spec_body
  end

  shared_examples "an optional positive integer flag" do
    it "defaults to nil" do
      flags = flagify()
      expect( flags.send(flag_name) ).to be nil
    end

    it "can be set to an integer larger than zero at initialization time" do
      flags = flagify(max_diffs: 1)
      expect( flags.send(flag_name) ).to eq( 1 )
    end

    it "can't be set to zero" do
      expect { flagify(flag_name => 0) }.to \
        raise_error( CheckPlease::InvalidFlag )
    end

    it "can't be set to a negative integer" do
      expect { flagify(flag_name => -1) }.to \
        raise_error( CheckPlease::InvalidFlag )
    end

    it "coerces a string value to an integer" do
      flags = flagify(flag_name => "42")
      expect( flags.send(flag_name) ).to eq( 42 )
    end
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
    let(:flag_name) { :max_diffs }
    it_behaves_like "an optional positive integer flag"
  end

  describe "#fail_fast" do
    let(:flag_name) { :fail_fast }
    it_behaves_like "a boolean flag"
  end

  describe "#max_depth" do
    let(:flag_name) { :max_diffs }
    it_behaves_like "an optional positive integer flag"
  end

  describe "select_paths" do
    let(:flag_name) { :select_paths }
    it_behaves_like "a path list" do
      let(:paths_to_add) { [ "/foo", "/bar" ] }
    end
  end

  describe "reject_paths" do
    let(:flag_name) { :reject_paths }
    it_behaves_like "a path list" do
      let(:paths_to_add) { [ "/foo", "/bar" ] }
    end
  end

  specify "select_paths and reject_paths can't both be set" do
    expect { flagify(select_paths: ["/foo"], reject_paths: ["/bar"]) }.to \
      raise_error( CheckPlease::InvalidFlag )
  end

  describe "match_by_key" do
    let(:flag_name) { :match_by_key }
    it_behaves_like "a path list" do
      let(:paths_to_add) { [ "/:id", "/foo/:id", "/bar/:id" ] }
    end
  end

  describe "match_by_value" do
    let(:flag_name) { :match_by_value }
    it_behaves_like "a path list" do
      let(:paths_to_add) { [ "/foo", "/bar" ] }
    end
  end

  describe "#indifferent_keys" do
    let(:flag_name) { :indifferent_keys }
    it_behaves_like "a boolean flag"
  end

  describe "#indifferent_values" do
    let(:flag_name) { :indifferent_values }
    it_behaves_like "a boolean flag"
  end

end
