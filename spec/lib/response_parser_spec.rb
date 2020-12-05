
RSpec.describe TFClient::ResponseParser do

  let(:fixtures_dir) { File.join("spec", "fixtures", "responses") }
  let(:scan_response) { File.read(File.join(fixtures_dir, "nav.txt"))  }
  let(:lines) { scan_response.lines }

  context ".is_list_item?" do
    it "returns true when line begins with a tab char" do
      expect(described_class.is_list_item?(line: "\thello,abc")).to be == true
    end

    it "returns false when line does not begin with a tab char" do
      expect(described_class.is_list_item?(line: nil)).to be == false
      expect(described_class.is_list_item?(line: "")).to be == false
      expect(described_class.is_list_item?(line: "hello,abc")).to be == false
    end
  end

  context ".collect_list_items" do
    it "returns lines that are list items until a non-item line is found" do
      actual = described_class.collect_list_items(lines: lines, start_index: 4)
      expected = [
        "[{index}] drag: {link_drag}|    [{index}] drag: {link_drag}|index=0|link_drag=170",
        "[{index}] drag: {link_drag}|    [{index}] drag: {link_drag}|index=4|link_drag=32",
        "[{index}] drag: {link_drag}|    [{index}] drag: {link_drag}|index=7|link_drag=51"
      ]
      expect(actual).to be == expected
    end
  end

  context ".tokenize_line" do
    it "returns a list of tokens with inner leading/trailing whitespace trimmed" do
      line = "\t{id} {name}|\t {id} {name}|id=1 |name=abc's Ship "
      actual = described_class.tokenize_line(line: line)
      expected = ["\t{id} {name}", "{id} {name}", "id=1", "name=abc's Ship"]
      expect(actual).to be == expected
    end
  end

  context ".label_and_translation" do
    it "returns a hash with label: and translation: from tokenized line" do
      line = "Coordinates: {x},{y}|Ordinates: {x},{y}|x=0|y=0"
      tokens = described_class.tokenize_line(line: line)

      actual = described_class.label_and_translation(tokens: tokens)
      expected = { label: "Coordinates", translation: "Ordinates" }
      expect(actual).to be == expected
    end
  end

  context ".nth_value_from_end" do
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
