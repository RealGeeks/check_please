require_relative 'shared'

RSpec.describe CheckPlease::Printers::Long do
  context "for two very simple hashes" do
    let(:ref) { { foo: "wibble", yak: "Hello world!" } }
    let(:can) { { bar: "wibble", yak: "Howdy globe!" } }
    let(:expected_output) {
      <<~EOF.strip
        /foo [missing]
          reference: "wibble"
          candidate: [no value]

        /yak [mismatch]
          reference: "Hello world!"
          candidate: "Howdy globe!"

        /bar [extra]
          reference: [no value]
          candidate: "wibble"
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
        /the_sun_is_a_mass_of_incandescent_gas_a_gigantic_nuclear_furnace [missing]
          reference: "where hydrogen is built into helium at a temperature of millions of degrees"
          candidate: [no value]

        /the_sun_is_a_miasma_of_incandescent_plasma [extra]
          reference: [no value]
          candidate: "the sun's not simply made out of gas"
      EOF
    }

    include_examples ".render"
  end
end
