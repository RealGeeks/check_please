RSpec.describe CheckPlease do
  it "has a version number" do
    expect(CheckPlease::VERSION).not_to be nil
  end

  describe ".render_diff" do
    let(:ref) { { foo: 42 } }
    let(:can) { { bar: 42 } }

    let(:expected_table) {
      <<~EOF
				TYPE    | PATH | REFERENCE | CANDIDATE
				--------|------|-----------|----------
				missing | /foo | 42        |
				extra   | /bar |           | 42
      EOF
    }
    let(:expected_json) {
      <<~EOF
        [
          { "type": "missing", "path": "/foo", "reference": 42, "candidate": null },
          { "type": "extra", "path": "/bar", "reference": null, "candidate": 42 }
        ]
      EOF
    }

    it "can return a table using table_print" do
      actual = CheckPlease.render_diff(ref, can, format: :table)
      expect( actual.strip ).to eq( expected_table.strip )
    end

    it "can return results in JSON, because why not" do
      actual = CheckPlease.render_diff(ref, can, format: :json)
      expect( actual.strip ).to eq( expected_json.strip )
    end

    it "defaults to the table_print format if you don't tell it what you want" do
      actual = CheckPlease.render_diff(ref, can)
      expect( actual.strip ).to eq( expected_table.strip )
    end
  end
end
