require 'json'

RSpec.describe CheckPlease do
  it "has a version number" do
    expect(CheckPlease::VERSION).not_to be nil
  end

  shared_examples ".render_diff" do
    let(:expected_table) {
      <<~EOF.strip
				TYPE    | PATH | REFERENCE | CANDIDATE
				--------|------|-----------|----------
				missing | /foo | wibble    |
				extra   | /bar |           | wibble
      EOF
    }
    let(:expected_json) {
      <<~EOF.strip
        [
          { "type": "missing", "path": "/foo", "reference": "wibble", "candidate": null },
          { "type": "extra", "path": "/bar", "reference": null, "candidate": "wibble" }
        ]
      EOF
    }

    it "can return a table using table_print" do
      actual = CheckPlease.render_diff(ref, can, format: :table)

      # table_print generates trailing whitespace, which is fine for display
      # but sucks for this test.  Get rid of it here, and not in the printer...
      actual = actual.lines.map(&:rstrip).join("\n")

      expect( actual ).to eq( expected_table )
    end

    it "can return results in JSON, because why not" do
      actual = CheckPlease.render_diff(ref, can, format: :json)
      expect( actual ).to eq( expected_json )
    end

    it "defaults to the table_print format if you don't tell it what you want" do
      table = CheckPlease.render_diff(ref, can, format: :table)
      default = CheckPlease.render_diff(ref, can)
      expect( default ).to eq( table )
    end
  end

  describe ".render_diff" do
    context "when given Ruby data structures" do
      let(:ref) { { foo: "wibble" } }
      let(:can) { { bar: "wibble" } }
      include_examples ".render_diff"
    end

    context "when given JSON strings" do
      let(:ref) { { foo: "wibble" }.to_json }
      let(:can) { { bar: "wibble" }.to_json }
      include_examples ".render_diff"
    end

    context "when given strings that aren't valid JSON" do
      let(:ref) { "foo" }
      let(:can) { "bar" }

      it "compares the values as strings" do
        expected = <<~EOF.strip
          TYPE     | PATH | REFERENCE | CANDIDATE
          ---------|------|-----------|----------
          mismatch | /    | foo       | bar
        EOF
        actual = CheckPlease.render_diff(ref, can, format: :table)
        expect( actual ).to eq( expected )
      end
    end
  end
end
