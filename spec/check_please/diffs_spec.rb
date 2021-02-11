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

  describe "output" do
    before do
      subject << CheckPlease::Diff.new(:missing,  "/foo",  42,             nil)
      subject << CheckPlease::Diff.new(:extra,    "/spam", nil,            23)
      subject << CheckPlease::Diff.new(:mismatch, "/yak",  "Hello world!", "Howdy globe!")
    end

    def render_as(format)
      CheckPlease::Printers.render(subject, format: format)
    end

		specify "#to_s defaults to the :table format" do
      expected = render_as(:table)
      expect( subject.to_s ).to eq( expected )
    end

    specify "#to_s takes an optional :format kwarg" do
      CheckPlease::Printers::FORMATS.each do |format|
        expected = render_as(format)
        expect( subject.to_s(format: format) ).to eq( expected )
      end
    end

    describe "format-specific output methods" do
      CheckPlease::Printers::PRINTERS_BY_FORMAT.each do |format, klass|
        specify "##{format} renders using #{klass}" do
          expected = render_as(format)
          expect( subject.send(format) ).to eq( expected )
        end
      end

      specify "#bogus_format raises NoMethodError" do
        expect { subject.bogus_format }.to raise_error( NoMethodError )
      end

      specify "#formats returns a list of formats to help remind forgetful developers what's available" do
        expect( subject.formats ).to eq( CheckPlease::Printers::FORMATS )
      end
    end
  end

end
