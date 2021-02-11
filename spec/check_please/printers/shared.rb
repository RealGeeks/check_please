RSpec.shared_examples ".render" do
  specify ".render produces the expected output" do
    diffs = CheckPlease.diff(ref, can)
    actual = described_class.render(diffs)

    if $debug
      puts "\nEXPECTED: <<<", expected_output, ">>>"
      puts "\nACTUAL: <<<", actual,          ">>>"
    end

    expect( actual ).to eq( expected_output )
  end
end

