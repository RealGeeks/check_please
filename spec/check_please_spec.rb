RSpec.describe CheckPlease do
  it "has a version number" do
    expect(CheckPlease::VERSION).not_to be nil
  end

  describe ".diff" do

    context "when given two 'boring' objects" do
      let(:ref) { 42 }
      let(:cnd) { 43 }

      it "has one diff for the top-level mismatch" do
        diffs = CheckPlease.diff(ref, cnd)
        expect( diffs.length ).to eq( 1 )

        diffs.first.tap do |diff|
          expect( diff.path      ).to eq( "/" )
          expect( diff.reference ).to eq( 42 )
          expect( diff.candidate ).to eq( 43 )
        end
      end
    end

  end
end
