RSpec.describe CheckPlease do
  it "has a version number" do
    expect(CheckPlease::VERSION).not_to be nil
  end

  describe ".render_diff" do
    let(:ref) { { foo: 42 } }
    let(:can) { { bar: 42 } }

    let(:expected_table) {
      <<~EOF.strip
				TYPE    | PATH | REFERENCE | CANDIDATE
				--------|------|-----------|----------
				missing | /foo | 42        |
				extra   | /bar |           | 42
      EOF
    }
    let(:expected_json) {
      <<~EOF.strip
        [
          { "type": "missing", "path": "/foo", "reference": 42, "candidate": null },
          { "type": "extra", "path": "/bar", "reference": null, "candidate": 42 }
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
end
