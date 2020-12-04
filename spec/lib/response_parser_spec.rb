
RSpec.describe TFClient::ResponseParser do

  let(:fixtures_dir) { File.join("spec", "fixtures", "responses") }
  let(:scan_response) { File.read(File.join(fixtures_dir, "scan.txt"))  }

  context "#tokenize_line" do
    it "returns a list of tokens with leading/trailing whitespace trimmed" do
      line = "{id} {name}|\t {id} {name}|id=1 |name=abc's Ship "
      actual = described_class.tokenize_line(line: line)
      expected = ["{id} {name}", "{id} {name}", "id=1", "name=abc's Ship"]
      expect(actual).to be == expected
    end
  end

  context "#label_and_translation" do
    it "returns a hash with label: and translation: from tokenized line" do
      line = "Coordinates: {x},{y}|Ordinates: {x},{y}|x=0|y=0"
      tokens = described_class.tokenize_line(line: line)

      actual = described_class.label_and_translation(tokens: tokens)
      expected = { label: "Coordinates", translation: "Ordinates" }
      expect(actual).to be == expected
    end
  end

  context "#nth_value_from_end" do
    it "returns the value part of id=value structure in the nth from end position" do
      line = "Coordinates: {x},{y}|Ordinates: {x},{y}|x=1|y=2"
      tokens = described_class.tokenize_line(line: line)

      actual = described_class.nth_value_from_end(tokens: tokens, n: 0)
      expect(actual).to be == "2"

      actual = described_class.nth_value_from_end(tokens: tokens, n: 1)
      expect(actual).to be == "1"
    end
  end

  context "parse scan" do

    # let(:parser) { described_class.new(command: "scan", response: scan_response) }
    #
    # it "returns meaning information" do
    #   actual = parser.parse
    #   puts actual
    #
    # end
  end
end
