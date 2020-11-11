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
