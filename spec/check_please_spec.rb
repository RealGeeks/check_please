require 'json'
require 'yaml'

RSpec.describe CheckPlease do
  it "has a version number" do
    expect(CheckPlease::VERSION).not_to be nil
  end

  describe ".diff" do
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

  # NOTE: .render_diff is so simple it's not even worth testing on its own
  # (also it's exercised by the integration specs)
end
