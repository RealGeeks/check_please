RSpec.describe CheckPlease::CLI do

  describe CheckPlease::CLI::Parser do
    subject { described_class.new("wibble") }

    describe "#consume_flags!" do
      def invoke!(args)
        subject.consume_flags!(args)
      end

      it "recognizes '-f json' as a valid format" do
        opts = invoke!(%w[ -f json ])
        expect( opts[:format] ).to eq( :json )
      end

      it "recognizes '--format json' as a valid format" do
        opts = invoke!(%w[ --format json ])
        expect( opts[:format] ).to eq( :json )
      end

      it "recognizes '-n 3' as limiting output to 3 diffs" do
        opts = invoke!(%w[ -n 3 ])
        expect( opts[:max_diffs] ).to eq( 3 )
      end

      it "recognizes '--max-diffs 3' as limiting output to 3 diffs" do
        opts = invoke!(%w[ --max-diffs 3 ])
        expect( opts[:max_diffs] ).to eq( 3 )
      end

      it "recognizes '--fail-fast' as limiting output to 1 diff" do
        opts = invoke!(%w[ --fail-fast ])
        expect( opts[:max_diffs] ).to eq( 1 )
      end

      it "complains if given an arg it doesn't recognize" do
        expect { invoke!(%w[ --welcome-to-zombocom ]) }.to \
          raise_error( described_class::UnrecognizedOption )
      end

      specify "recognized args are removed from the args" do
        args = %w[ -f json ]
        invoke!(args)
        expect( args ).to be_empty
      end
    end
  end

end
