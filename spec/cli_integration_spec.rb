require 'open3'
require 'timeout'

RSpec.describe "bin/check_please executable" do

  context "for a ref/can pair with a few discrepancies" do
    let(:ref_file) { "spec/fixtures/forty-two-reference.json" }
    let(:can_file) { "spec/fixtures/forty-two-candidate.json" }

    let(:expected_table) {
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
    let(:expected_json) {
      <<~EOF.strip
        [
          { "type": "type_mismatch", "path": "/name", "reference": "The Answer", "candidate": [ "I am large, and contain multitudes." ] },
          { "type": "mismatch", "path": "/words/3", "reference": "you", "candidate": "we" },
          { "type": "mismatch", "path": "/words/6", "reference": "you", "candidate": "I" },
          { "type": "extra", "path": "/words/11", "reference": null, "candidate": "dude" },
          { "type": "missing", "path": "/meta/bar", "reference": "eggs", "candidate": null },
          { "type": "mismatch", "path": "/meta/foo", "reference": "spam", "candidate": "foo" }
        ]
      EOF
    }

    describe "running the executable with two filenames" do
      it "produces tabular output" do
        output = run_cli(ref_file, can_file)
        expect( output ).to eq( expected_table )
      end

      specify "adding `-f json` produces JSON output" do
        output = run_cli(ref_file, can_file, "-f", "json")
        expect( output ).to eq( expected_json )
      end

      specify "adding `--fail-fast` limits output to one row" do
        output = run_cli(ref_file, can_file, "--fail-fast")
        expect( output.lines.length ).to be < expected_table.lines.length
      end

      specify "adding an unrecognized flag complains about the flag, prints help, and exits" do
        output = run_cli(ref_file, can_file, "--welcome-to-zombocom")
        expect( output ).to include( "--welcome-to-zombocom" )
        expect( output ).to include( CheckPlease::ELEVATOR_PITCH )
      end
    end

    describe "running the executable with one filename" do
      it "reads the candidate from piped stdin" do
        output = run_cli(ref_file, pipe: can_file)
        expect( output ).to eq( expected_table )
      end

      specify "prints help and exits if the user didn't pipe anything in" do
        output = run_cli(ref_file)
        expect( output ).to include( CheckPlease::ELEVATOR_PITCH )
      end
    end

    describe "running the executable with only flags" do
      specify "complains about missing reference, prints help and exits" do
        output = run_cli("-f json")
        expect( output ).to include( CheckPlease::ELEVATOR_PITCH )
        expect( output ).to include( "Missing <reference>" )
      end
    end

    describe "running the executable with no arguments" do
      specify "prints help and exits" do
        output = run_cli("")
        expect( output ).to include( CheckPlease::ELEVATOR_PITCH )
        expect( output ).to_not include( "Missing <reference>" )
      end
    end
  end

end
