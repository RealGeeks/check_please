require 'open3'
require 'timeout'

RSpec.describe "bin/check_please executable" do

  # these tests can hang if I screw up, which happens a lot, so...
  TIMEOUT_AFTER = 2 # seconds
  around do |example|
    Timeout.timeout(TIMEOUT_AFTER) do
      example.run
    end
  end

  context "for a ref/can pair with a few discrepancies" do
    let(:ref_file) { "spec/fixtures/forty-two-reference.json" }
    let(:can_file) { "spec/fixtures/forty-two-candidate.json" }

    let(:expected) {
      <<~EOF.strip
        TYPE          | PATH      | REFERENCE  | CANDIDATE
        --------------|-----------|------------|-------------------------------
        type_mismatch | /name     | The Answer | ["I am large, and contain m...
        mismatch      | /words/3  | you        | we
        mismatch      | /words/6  | you        | I
        extra         | /words/11 |            | dude
        missing       | /meta/bar | eggs       |
        mismatch      | /meta/foo | spam       | foo
      EOF
    }

    specify "running the executable with both filenames produces tabular output" do
      actual = `bin/check_please #{ref_file} #{can_file}`
      actual = strip_trailing_whitespace(actual)
      expect( actual ).to eq( expected )
    end

    specify "if the second filename is omitted, executable looks for its content on stdin" do
      candidate_json = File.read(can_file)

      actual = nil # scope hack
      Open3.popen3( "bin/check_please #{ref_file}") do |stdin, stdout, stderr, wait_thr|
        stdin.puts candidate_json
        stdin.close
        wait_thr.value # wait for process to finish
        actual = stdout.read
      end

      actual = strip_trailing_whitespace(actual)

      expect( actual ).to eq( expected )
    end

    specify "if the second filename is omitted AND the user didn't pipe anything in, executable prints --help and exits" do
      actual = `bin/check_please #{ref_file}`
      actual = strip_trailing_whitespace(actual)
      expect( actual ).to match( /^Usage:/ )
    end
  end

end
