require_relative 'shared'

RSpec.describe CheckPlease::Printers::TablePrint do
  context "for two very simple hashes" do
    let(:ref) { { foo: "wibble" } }
    let(:can) { { bar: "wibble" } }
    let(:expected_output) {
      <<~EOF.strip
        TYPE    | PATH | REFERENCE | CANDIDATE
        --------|------|-----------|----------
        missing | /foo | "wibble"  |
        extra   | /bar |           | "wibble"
      EOF
    }

    include_examples ".render"
  end

  context "for two very simple hashes that are equal" do
    let(:ref) { { foo: "wibble" } }
    let(:can) { { foo: "wibble" } }
    let(:expected_output) { "" }

    include_examples ".render"
  end

  context "for two hashes with relatively long keys" do
    let(:ref) { { the_sun_is_a_mass_of_incandescent_gas_a_gigantic_nuclear_furnace: "where hydrogen is built into helium at a temperature of millions of degrees" } }
    let(:can) { { the_sun_is_a_miasma_of_incandescent_plasma:                       "the sun's not simply made out of gas" } }
    let(:expected_output) {
      <<~EOF.strip
        TYPE    | PATH                                                              | REFERENCE                      | CANDIDATE
        --------|-------------------------------------------------------------------|--------------------------------|-------------------------------
        missing | /the_sun_is_a_mass_of_incandescent_gas_a_gigantic_nuclear_furnace | "where hydrogen is built in... |
        extra   | /the_sun_is_a_miasma_of_incandescent_plasma                       |                                | "the sun's not simply made ...
      EOF
    }

    include_examples ".render"
  end
end
