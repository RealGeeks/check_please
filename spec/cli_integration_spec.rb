require 'open3'
require 'timeout'

RSpec.describe "bin/check_please executable", :cli do

  ###############################################
  ##                                           ##
  ##  ##    ##    #####   ########  ########   ##
  ##  ###   ##   ##   ##     ##     ##         ##
  ##  ####  ##  ##     ##    ##     ##         ##
  ##  ## ## ##  ##     ##    ##     ######     ##
  ##  ##  ####  ##     ##    ##     ##         ##
  ##  ##   ###   ##   ##     ##     ##         ##
  ##  ##    ##    #####      ##     ########   ##
  ##                                           ##
  ###############################################
  # NOTE: These tests are slow (relative to everything else).
  # Please only add specs here for behavior that you can't possibly test any other way.
  ###############################################

  specify "output of -h/--help" do
    # NOTE: this spec is hand-rolled because I don't expect to have any more like
    # it.  I considered using the 'approvals' gem, but it drags in a dependency
    # on Nokogiri that I wanted to avoid.  If you do find yourself needing to do
    # more specs like this, 'approvals' might be useful...

    expected = fixture_file_contents("cli-help-output").rstrip
    output = run_cli("--help").rstrip

    begin
      expect( output ).to eq( expected )
    rescue RSpec::Expectations::ExpectationNotMetError => e
      puts <<~EOF

        --> NOTE: the output of the executable's `--help` flag has changed.
        --> If you want to keep these changes, please run:
        -->
        -->   bundle exec rake spec:approve_cli_help_output

      EOF
      raise e
    end
  end

  context "for a ref/can pair with a few discrepancies" do
    let(:ref_file) { "spec/fixtures/forty-two-reference.json" }
    let(:can_file) { "spec/fixtures/forty-two-candidate.json" }
    let(:expected_output) { fixture_file_contents("forty-two-expected-table").strip }

    describe "running the executable with two filenames" do
      it "produces tabular output" do
        output = run_cli(ref_file, can_file)
        expect( output ).to eq( expected_output )
      end

      specify "adding `--fail-fast` limits output to one row" do
        output = run_cli(ref_file, can_file, "--fail-fast")
        expect( output.lines.length ).to be < expected_output.lines.length
      end
    end

    describe "running the executable with one filename" do
      it "reads the candidate from piped stdin" do
        output = run_cli(ref_file, pipe: can_file)
        expect( output ).to eq( expected_output )
      end

      specify "prints help and exits if the user didn't pipe anything in" do
        output = run_cli(ref_file)
        expect( output ).to include( CheckPlease::ELEVATOR_PITCH )
      end
    end

    describe "running the executable with no arguments" do
      specify "prints a message about the missing reference and exits" do
        output = run_cli()
        expect( output ).to include( CheckPlease::ELEVATOR_PITCH )
        expect( output ).to_not include( "Missing <reference>" )
      end
    end
  end

  context "for a ref/can pair with two simple objects in reverse order" do
    let(:ref_file) { "spec/fixtures/match-by-key-reference.json" }
    let(:can_file) { "spec/fixtures/match-by-key-candidate.json" }

    specify "--match-by-key works end to end" do
      output = run_cli(ref_file, can_file, "--match-by-key", "/:id")
      expect( output ).to be_empty
    end
  end

  TIME_OUT_CLI_AFTER = 1 # seconds
  def run_cli(*args, pipe: nil)
    args.flatten!

    cmd = []
    if pipe
      cmd << "cat"
      cmd << pipe
      cmd << "|"
    end
    cmd << "exe/check_please"
    cmd.concat args

    out = nil # scope hack
    Timeout.timeout(TIME_OUT_CLI_AFTER) do
      out = `#{cmd.compact.join(' ')}`
    end
    strip_trailing_whitespace(out)
  end

end
