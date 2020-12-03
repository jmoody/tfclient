
RSpec.describe TFClient::ResponseParser do

  let(:fixtures_dir) { File.join("spec", "fixtures", "responses") }
  let(:scan_response) { File.read(File.join(fixtures_dir, "scan.txt"))  }

  context "parse scan" do
    context "#tokenize_line" do
      it "returns a list of tokens with leading/trailing whitespace trimmed" do
        line = "{id} {name}|\t {id} {name}|id=1 |name=abc's Ship "
        actual = described_class.tokenize_lines(line)
        expected = ["{id} {name}", "{id} {name}", "id=1", "name=abc's Ship"]
        expect(actual).to be == expected
      end
    end

    # let(:parser) { described_class.new(command: "scan", response: scan_response) }
    #
    # it "returns meaning information" do
    #   actual = parser.parse
    #   puts actual
    #
    # end
  end
end
