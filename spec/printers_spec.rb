RSpec.describe CheckPlease::Printers do

  describe ".render" do
    let(:ref) { { "answer" => 42 } }
    let(:can) { { "answer" => 43 } }
    let(:diffs) { CheckPlease.diff(ref, can) }

    it "renders using the TablePrint printer when given `format: :table`" do
      expect( CheckPlease::Printers::TablePrint ).to receive(:render).with(diffs)
      CheckPlease::Printers.render(diffs, format: :table)
    end

    it "renders using the TablePrint printer when not given a `format:` kwarg" do
      expect( CheckPlease::Printers::TablePrint ).to receive(:render).with(diffs)
      CheckPlease::Printers.render(diffs)
    end

    it "renders using the JSON printer when given `format: :json`" do
      expect( CheckPlease::Printers::JSON ).to receive(:render).with(diffs)
      CheckPlease::Printers.render(diffs, format: :json)
    end
  end

end
