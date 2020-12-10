
RSpec.describe TFClient::ResponseParser do

  let(:fixtures_dir) { File.join("spec", "fixtures", "responses") }
  let(:nav_response) { File.read(File.join(fixtures_dir, "nav.txt"))  }
  let(:lines) { nav_response.lines }

  context ".hash_with_values" do
    it "returns a hash with the key=value pairs at the end of a line" do
      actual = described_class.hash_from_line_values(line: lines[0])
      expect(actual).to be == {x: "1", y: "2"}

      actual = described_class.hash_from_line_values(line: lines[1])
      expect(actual).to be == {faction: "nibiru"}

      actual = described_class.hash_from_line_values(line: lines[6])
      expect(actual).to be == {index: "4", link_drag: "32"}

      actual = described_class.hash_from_line_values(line: lines[7])
      expect(actual).to be == {index: "5", faction: "nibiru", link_drag: "90"}

      actual = described_class.hash_from_line_values(line: lines[10])
      expect(actual).to be == {index: "0", planet_type: "GAS"}

      actual = described_class.hash_from_line_values(line: lines[12])
      expect(actual).to be == {
        index: "6", name: "notwendig", faction: "nibiru", planet_type: "Habitable"
      }

      actual = described_class.hash_from_line_values(line: lines[15])
      expect(actual).to be == {id: "123", name: "abc's Ship", sclass: "AST"}

      actual = described_class.hash_from_line_values(line: lines[18])
      expect(actual).to be == {id: "360", name: "hafen-9"}
    end
  end

  context ".line_and_index_for_label" do
    it "returns the line and index that begins with label" do
      line, index = described_class.line_and_index_for_label(lines: lines, label: "Coordinates")
      expect(line).to be == "Coordinates: {x},{y}|Koordinaten: {x},{y}|x=1|y=2"
      expect(index).to be == 0

      line, index = described_class.line_and_index_for_label(lines: lines, label: "Planets")
      expect(line).to be == "Planets:|Planeten:"
      expect(index).to be == 9
    end

    it "returns nil, nil if no line begins with label" do
      line, index = described_class.line_and_index_for_label(lines: lines,
                                                             label: "Comets")
      expect(line).to be == nil
      expect(index).to be == -1
    end
  end

  context ".tokens_and_index_for_label" do
    it "returns the line that begins with label, tokenized" do
      tokens, index = described_class.tokens_and_index_for_label(lines: lines,
                                                                 label: "Coordinates")
      expect(tokens.count).to be == 4
      expect(index).to be == 0

      tokens, index = described_class.tokens_and_index_for_label(lines: lines,
                                                                 label: "Planets")
      expect(tokens.count).to be == 2
      expect(index).to be == 9
    end

    it "returns nil if not line begins with label" do
      tokens, index = described_class.line_and_index_for_label(lines: lines,
                                                               label: "Comets")
      expect(tokens).to be == nil
      expect(index).to be == -1
    end
  end

  context ".index_of_label" do
    it "returns the index of the line that begins with label" do
      actual = described_class.index_of_label(lines: lines, label: "Coordinates")
      expect(actual).to be == 0

      actual = described_class.index_of_label(lines: lines, label: "Links")
      expect(actual).to be == 4

      actual = described_class.index_of_label(lines: lines, label: "Structures")
      expect(actual).to be == 14
    end

    it "returns nil there is no line that begins with label" do
      actual = described_class.index_of_label(lines: lines, label: "Lumen")
      expect(actual).to be == nil
    end
  end

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
      actual = described_class.collect_list_items(lines: lines, start_index: 5)

      expected = [
        "[{index}] drag: {link_drag}|    [{index}] drag: {link_drag}|index=0|link_drag=170",
        "[{index}] drag: {link_drag}|    [{index}] drag: {link_drag}|index=4|link_drag=32",
        "[{index}] (faction: {faction}) drag: {link_drag}|       [{index}] (faction: {faction}) drag: {link_drag}|index=5|faction=nibiru|link_drag=90",
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

    it "returns a hash with label: and translation: from a 'Claimed by' line" do
      line = "Claimed by '{faction}'.|Beansprucht von '{faction}'.|faction=nibiru"
      tokens = described_class.tokenize_line(line: line)

      actual = described_class.label_and_translation(tokens: tokens)
      expected = { label: "Claimed by", translation: "Beansprucht von"}
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

  context ".model_class_from_label" do
    it "returns a class in TFClient::Models for the label" do
      actual = described_class.model_class_from_label(label: "Coordinates")
      expect(actual.is_a?(Class)).to be == true
      expect(actual.to_s).to be == "TFClient::Models::Coordinates"
    end

    it "returns nil if no class in TFClient::Models matches the label" do
      actual = described_class.model_class_from_label(label: "Comets")
      expect(actual).to be == nil
    end
  end

  context "#parse_nav" do
    it "returns a string that is ready to be printed" do
      hash = TFClient::ResponseParser.new(command: "nav", response: nav_response).parse

      puts hash

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
