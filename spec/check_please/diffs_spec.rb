RSpec.describe CheckPlease::Diffs do
  subject { described_class.new }

  describe "lookups using #[]" do
    # NOTE: this feature makes other tests slightly more robust, in that they
    # can be indifferent to the specific ordering of diffs while still
    # comprehensively specifying that the correct diffs are there.

    let(:foo) { instance_double(CheckPlease::Diff, path: "foo") }
    let(:bar) { instance_double(CheckPlease::Diff, path: "bar") }

    before do
      subject << foo
      subject << bar
    end

    it "treats integers like array indices" do
      expect( subject[0] ).to be foo
      expect( subject[1] ).to be bar
    end

    it "treats strings like hash keys, looking diffs up by their path" do
      expect( subject["bar"] ).to be bar
      expect( subject["foo"] ).to be foo
    end
  end

end
