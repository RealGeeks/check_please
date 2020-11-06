require 'json'

RSpec.describe CheckPlease do
  it "has a version number" do
    expect(CheckPlease::VERSION).not_to be nil
  end

  describe ".render_diff" do
    shared_examples ".render_diff" do
      it "can return a table using table_print" do
        actual = CheckPlease.render_diff(ref, can, format: :table)

        # table_print generates trailing whitespace, which is fine for display
        # but sucks for this test.  Get rid of it here, and not in the printer...
        actual = strip_trailing_whitespace(actual)

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

    context "for two very simple hashes" do
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
      let(:ref_hash) { { foo: "wibble" } }
      let(:can_hash) { { bar: "wibble" } }

      context "when given Ruby data structures" do
        let(:ref) { ref_hash }
        let(:can) { can_hash }
        include_examples ".render_diff"
      end

      context "when given JSON strings" do
        let(:ref) { ref_hash.to_json }
        let(:can) { can_hash.to_json }
        include_examples ".render_diff"
      end
    end

    context "for two very simple hashes that are equal" do
      let(:expected_table) { "" }
      let(:expected_json) { "[]" }
      let(:ref_hash) { { foo: "wibble" } }
      let(:can_hash) { { foo: "wibble" } }

      context "when given Ruby data structures" do
        let(:ref) { ref_hash }
        let(:can) { can_hash }
        include_examples ".render_diff"
      end

      context "when given JSON strings" do
        let(:ref) { ref_hash.to_json }
        let(:can) { can_hash.to_json }
        include_examples ".render_diff"
      end
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

    context "for two hashes with relatively long keys" do
      let(:ref) { { the_sun_is_a_mass_of_incandescent_gas_a_gigantic_nuclear_furnace: "where hydrogen is built into helium at a temperature of millions of degrees" } }
      let(:can) { { the_sun_is_a_miasma_of_incandescent_plasma:                       "the sun's not simply made out of gas" } }
      let(:expected_table) {
        <<~EOF.strip
          TYPE    | PATH                                                              | REFERENCE                      | CANDIDATE
          --------|-------------------------------------------------------------------|--------------------------------|-------------------------------
          missing | /the_sun_is_a_mass_of_incandescent_gas_a_gigantic_nuclear_furnace | where hydrogen is built int... |
          extra   | /the_sun_is_a_miasma_of_incandescent_plasma                       |                                | the sun's not simply made o...
        EOF
      }
      let(:expected_json) {
        <<~EOF.strip
          [
            { "type": "missing", "path": "/the_sun_is_a_mass_of_incandescent_gas_a_gigantic_nuclear_furnace", "reference": "where hydrogen is built into helium at a temperature of millions of degrees", "candidate": null },
            { "type": "extra", "path": "/the_sun_is_a_miasma_of_incandescent_plasma", "reference": null, "candidate": "the sun's not simply made out of gas" }
          ]
        EOF
      }

      include_examples ".render_diff"
    end
  end
end
