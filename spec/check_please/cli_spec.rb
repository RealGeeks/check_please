RSpec.describe CheckPlease::CLI do

  describe CheckPlease::CLI::Parser do
    subject { described_class.new("wibble") }

    describe "#flags_from_args!" do
      def invoke!(args)
        subject.flags_from_args!(args)
      end

      it "recognizes '-f json' as a valid format" do
        flags = invoke!(%w[ -f json ])
        expect( flags.format ).to eq( :json )
      end

      it "recognizes '--format json' as a valid format" do
        flags = invoke!(%w[ --format json ])
        expect( flags.format ).to eq( :json )
      end

      it "recognizes '-n 3' as limiting output to 3 diffs" do
        flags = invoke!(%w[ -n 3 ])
        expect( flags.max_diffs ).to eq( 3 )
      end

      it "recognizes '--max-diffs 3' as limiting output to 3 diffs" do
        flags = invoke!(%w[ --max-diffs 3 ])
        expect( flags.max_diffs ).to eq( 3 )
      end

      it "recognizes '--fail-fast' as setting the :fail_fast flag to true" do
        flags = invoke!(%w[ --fail-fast ])
        expect( flags.fail_fast ).to be true
      end

      it "recognizes '--max-depth 2' as limiting recursion to 2 levels" do
        flags = invoke!(%w[ --max-depth 2 ])
        expect( flags.max_depth ).to eq( 2 )
      end

      it "complains if given an arg it doesn't recognize" do
        expect { invoke!(%w[ --welcome-to-zombocom ]) }.to \
          raise_error( CheckPlease::InvalidFlag )
      end

      specify "recognized args are removed from the args" do
        args = %w[ -f json ]
        invoke!(args)
        expect( args ).to be_empty
      end
    end
  end

end
