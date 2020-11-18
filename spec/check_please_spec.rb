require 'json'
require 'yaml'

RSpec.describe CheckPlease do
  it "has a version number" do
    expect(CheckPlease::VERSION).not_to be nil
  end

  describe ".diff" do
    context "with two very simple hashes" do
      let(:ref) { { "answer" => 42 } }
      let(:can) { { "answer" => 43 } }

      def assert_diffs(diffs)
        expect( diffs ).to be_a(CheckPlease::Diffs)
        expect( diffs.length ).to eq( 1 )

        diff = diffs[0]
        expect( diff.path ).to eq( "/answer" )
        expect( diff.reference ).to eq( 42 )
        expect( diff.candidate ).to eq( 43 )
      end

      it "takes a reference and a candidate, compares them, and returns a Diffs" do
        assert_diffs CheckPlease.diff(ref, can)
      end

      it "parses the reference from JSON if it's in JSON" do
        assert_diffs CheckPlease.diff(ref.to_json, can)
      end

      it "parses the candidate from JSON if it's in JSON" do
        assert_diffs CheckPlease.diff(ref, can.to_json)
      end

      it "parses the reference from YAML if it's in YAML" do
        assert_diffs CheckPlease.diff(ref.to_yaml, can)
      end

      it "parses the candidate from YAML if it's in YAML" do
        assert_diffs CheckPlease.diff(ref, can.to_yaml)
      end
    end

    describe "across supported input formats (not that anyone would actually DO this...)" do
      let(:ref_json) { fixture_file_contents("forty-two-reference.json") }
      let(:ref_yaml) { fixture_file_contents("forty-two-reference.yaml") }
      let(:can_json) { fixture_file_contents("forty-two-candidate.json") }
      let(:can_yaml) { fixture_file_contents("forty-two-candidate.yaml") }

      FORMATS = %w[ json yaml ]

      # Don't metaprogram your specs at home, kids!
      FORMATS.each do |ref_format|
        FORMATS.each do |can_format|
          it "can compare #{ref_format.upcase} to #{can_format.upcase}" do
            ref = send("ref_#{ref_format}")
            can = send("can_#{can_format}")
            diffs = CheckPlease.diff(ref, can)
            expect( diffs.length ).to eq( 6 )
          end
        end
      end
    end
  end

  # NOTE: .render_diff is so simple it's not even worth testing on its own
  # (also it's exercised by the integration specs)
end
