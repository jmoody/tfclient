
RSpec.describe TFClient::Models::Server::Parser do

  let(:fixtures_dir) { File.join("spec", "fixtures", "responses") }
  let(:nav_response) { File.read(File.join(fixtures_dir, "nav.txt"))  }
  let(:lines) { nav_response.lines }
  let(:parser) do
    Class.new do
      include TFClient::Models::Server::Parser

      def to_s; inspect; end
      def inspect; "#<AnonymousParser>"; end
    end.new
  end

  context "#substitute_values" do
    it "returns the same string if there is no pipe char" do
      line = "Planets:\n"
      actual = parser.substitute_line_values(line: line)
      expect(actual).to be == line.chomp
    end

    it "returns the translated token if there are no substitutions" do
      line = "Planets:|Planeten:\n"
      actual = parser.substitute_line_values(line: line)
      expect(actual).to be == "Planeten:"
    end

    it "returns string with values substituted" do
      line = "[{index}] (faction: {faction}) drag: {link_drag}|\t[{index}] (faction: {faction}) drag: {link_drag}|index=5|faction=nibiru|link_drag=90\n"
      actual = parser.substitute_line_values(line: line)
      expect(actual).to be == "\t[5] (faction: nibiru) drag: 90"
    end
  end

  context "#hash_with_values" do
    it "returns a hash with the key=value pairs at the end of a line" do
      actual = parser.hash_from_line_values(line: lines[0])
      expect(actual).to be == {x: "1", y: "2"}

      actual = parser.hash_from_line_values(line: lines[1])
      expect(actual).to be == {faction: "nibiru"}

      actual = parser.hash_from_line_values(line: lines[2])
      expect(actual).to be == { name: "guertel" }

      actual = parser.hash_from_line_values(line: lines[7])
      expect(actual).to be == {index: "4", link_drag: "32"}

      actual = parser.hash_from_line_values(line: lines[8])
      expect(actual).to be == {index: "5", faction: "nibiru", link_drag: "90"}

      actual = parser.hash_from_line_values(line: lines[11])
      expect(actual).to be == {index: "0", planet_type: "GAS"}

      actual = parser.hash_from_line_values(line: lines[13])
      expect(actual).to be == {
        index: "6", name: "notwendig", faction: "nibiru", planet_type: "Habitable"
      }

      actual = parser.hash_from_line_values(line: lines[16])
      expect(actual).to be == {id: "123", name: "abc's Ship", sclass: "AST"}

      actual = parser.hash_from_line_values(line: lines[19])
      expect(actual).to be == {id: "360", name: "hafen-9"}
    end
  end

  context "#line_and_index_for_label" do
    it "returns the line and index that begins with label" do
      line, index = parser.line_and_index_for_beginning_with(lines: lines, string: "Coordinates")
      expect(line).to be == "Coordinates: {x},{y}|Koordinaten: {x},{y}|x=1|y=2"
      expect(index).to be == 0

      line, index = parser.line_and_index_for_beginning_with(lines: lines, string: "Planets")
      expect(line).to be == "Planets:|Planeten:"
      expect(index).to be == 10
    end

    it "returns nil, nil if no line begins with label" do
      line, index = parser.line_and_index_for_beginning_with(lines: lines,
                                                             string: "Comets")
      expect(line).to be == nil
      expect(index).to be == -1
    end
  end

  context "#is_list_item?" do
    it "returns true when line begins with a tab char" do
      expect(parser.is_list_item?(line: "\thello,abc")).to be == true
    end

    it "returns false when line does not begin with a tab char" do
      expect(parser.is_list_item?(line: nil)).to be == false
      expect(parser.is_list_item?(line: "")).to be == false
      expect(parser.is_list_item?(line: "hello,abc")).to be == false
    end
  end

  context "#collect_list_items" do
    it "returns lines that are list items until a non-item line is found" do
      actual = parser.collect_list_items(lines: lines, start_index: 6)

      expected = [
        "[{index}] drag: {link_drag}|    [{index}] drag: {link_drag}|index=0|link_drag=170",
        "[{index}] drag: {link_drag}|    [{index}] drag: {link_drag}|index=4|link_drag=32",
        "[{index}] (faction: {faction}) drag: {link_drag}|       [{index}] (faction: {faction}) drag: {link_drag}|index=5|faction=nibiru|link_drag=90",
        "[{index}] drag: {link_drag}|    [{index}] drag: {link_drag}|index=7|link_drag=51"
      ]
      expect(actual).to be == expected
    end
  end

  context "#tokenize_line" do
    it "returns a list of tokens with inner leading/trailing whitespace trimmed" do
      line = "\t{id} {name}|\t {id} {name}|id=1 |name=abc's Ship "
      actual = parser.tokenize_line(line: line)
      expected = ["\t{id} {name}", "{id} {name}", "id=1", "name=abc's Ship"]
      expect(actual).to be == expected
    end
  end

  context "#label_and_translation" do
    it "returns a hash with label: and translation: from tokenized line" do
      line = "Coordinates: {x},{y}|Ordinates: {x},{y}|x=0|y=0"
      tokens = parser.tokenize_line(line: line)

      actual = parser.label_and_translation(tokens: tokens)
      expected = { label: "Coordinates", translation: "Ordinates" }
      expect(actual).to be == expected
    end

    it "returns a hash with label: and translation: from a 'Claimed by' line" do
      line = "Claimed by '{faction}'.|Beansprucht von '{faction}'.|faction=nibiru"
      tokens = parser.tokenize_line(line: line)

      actual = parser.label_and_translation(tokens: tokens)
      expected = { label: "Claimed by", translation: "Beansprucht von"}
      expect(actual).to be == expected
    end
  end

  context "#camel_case_from_label" do
    it "returns a camel-case string from label" do
      actual = parser.camel_case_from_string(string: "Coordinates")
      expect(actual).to be == "Coordinates"

      actual = parser.camel_case_from_string(string: "Claimed by")
      expect(actual).to be == "ClaimedBy"

      actual = parser.camel_case_from_string(string: "A b c")
      expect(actual).to be == "ABC"
    end
  end

  context ".snake_case_sym_from_label" do
    it "returns a snake-case symbol from label" do
      actual = parser.snake_case_sym_from_string(string: "Coordinates")
      expect(actual).to be == :coordinates

      actual = parser.snake_case_sym_from_string(string: "Claimed by")
      expect(actual).to be == :claimed_by

      actual = parser.snake_case_sym_from_string(string: "A b c")
      expect(actual).to be == :a_b_c
    end
  end

  context "#model_class_from_label" do
    it "returns a class in TFClient::Models for the label" do
      actual = parser.model_class_from_string(string: "Coordinates")
      expect(actual.is_a?(Class)).to be == true
      expect(actual.to_s).to be == "TFClient::Models::Server::Coordinates"
    end

    it "returns nil if no class in TFClient::Models matches the label" do
      actual = parser.model_class_from_string(string: "Comets")
      expect(actual).to be == nil
    end
  end

  context "#status_from_line" do
    context "cooling" do
      it "returns a status from a stable line" do
        lines = ["	Cooling status: Stable| Kühlstatus: Stabil"]
        actual, translation = parser.status_from_lines(
          lines: lines,
          start_with: "Cooling status"
        )
        expect(actual).to be == "Stable"
        expect(translation).to be == "Kühlstatus: Stabil"
      end

      it "returns a status from an overheated line" do
        lines = ["	Cooling status: OVERHEATED|     Kühlstatus: Überhitzt"]
        actual, translation = parser.status_from_lines(
          lines: lines,
          start_with: "Cooling status"
        )
        expect(actual).to be == "Overheated"
        expect(translation).to be == "Kühlstatus: Überhitzt"
      end

      it "returns a status from an overheating in N seconds line" do
        lines = ["	Cooling status: Overheat in {remaining} seconds!|       Kühlstatus: Überhitzung in {remaining} Sekunden!|remaining=46"]
        actual, translation = parser.status_from_lines(
          lines: lines,
          start_with: "Cooling status"
        )
        expect(actual).to be == "Overheating"
        expect(translation).to be == "Kühlstatus: Überhitzung in 46 Sekunden!"
      end
    end

    context "power status" do
      it "returns a status from a stable line" do
        lines = ["	Power status: Stable|   Stromstatus: Stabil" ]
        actual, translation = parser.status_from_lines(
          lines: lines,
          start_with: "Power status"
        )
        expect(actual).to be == "Stable"
        expect(translation).to be == "Stromstatus: Stabil"
      end

      it "returns a status from a brown line" do
        lines = [" Power status: BROWNOUT| Stromstatus: Stromausfall" ]
        actual, translation = parser.status_from_lines(
          lines: lines,
          start_with: "Power status"
        )
        expect(actual).to be == "Brownout"
        expect(translation).to be == "Stromstatus: Stromausfall"
      end

      it "returns a status from an overheating in N seconds line" do
        lines = [ 	"Power status: Brownout in {remaining} seconds!| Stromstatus: Stromausfall in {remaining} Sekunden!|remaining=11"]
        actual, translation = parser.status_from_lines(
          lines: lines,
          start_with: "Power status"
        )
        expect(actual).to be == "Overloaded"
        expect(translation).to be == "Stromstatus: Stromausfall in 11 Sekunden!"
      end
    end

    context "engines" do
      it "returns a status from a ready line" do
        lines = ["	Warp engines: Ready to engage|Warp-Motoren: Bereit zum Einschalten"]
        actual, translation = parser.status_from_lines(
          lines: lines,
          start_with: "Warp engines"
        )
        expect(actual).to be == "Ready"
        expect(translation).to be == "Warp-Motoren: Bereit zum Einschalten"
      end

      it "returns a status from a recharging line" do
        lines = ["  Warp engines: Charging ({charge}%)|Warp-Motoren: Aufladen ({charge}%)|charge=97"]
        actual, translation = parser.status_from_lines(
          lines: lines,
          start_with: "Warp engines"
        )
        expect(actual).to be == "Charging"
        expect(translation).to be == "Warp-Motoren: Aufladen (97%)"
      end

      it "returns a status from a offline line" do
        lines = [ "Warp engines: Offline|Warp-Motoren: Offline" ]
        actual, translation = parser.status_from_lines(
          lines: lines,
          start_with: "Warp engines"
        )
        expect(actual).to be == "Offline"
        expect(translation).to be == "Warp-Motoren: Offline"
      end
    end

    context "shield" do
      it "returns a status from a 'online' line" do
        lines = ["	Shields: Online|Schilde: Bereit" ]
        actual, translation = parser.status_from_lines(
          lines: lines,
          start_with: "Shields"
        )
        expect(actual).to be == "Online"
        expect(translation).to be == "Schilde: Bereit"
      end

      it "returns a status from a failed line" do
        lines = ["	Shields: FAILED|Schilde: Gescheitert" ]
        actual, translation = parser.status_from_lines(
          lines: lines,
          start_with: "Shields"
        )
        expect(actual).to be == "Failed"
        expect(translation).to be == "Schilde: Gescheitert"
      end

      it "returns status from a regenerating line" do
        lines = ["Shields: Regenerating at {rate}/s ({shield}/{max})|Schilde: Regenerieren bei {rate}/s ({shield}/{max})|shield=24|max=60|rate=0.2"]
        actual, translation = parser.status_from_lines(
          lines: lines,
          start_with: "Shields"
        )
        expect(actual).to be == "Regenerating"
        expect(translation).to be == "Schilde: Regenerieren bei 0.2/s (24/60)"
      end
    end

    context "antigravity" do
      it "returns a status from a 'online' line" do
        lines = ["Antigravity engines: Online|Antigravitationsmotoren: Activ"]
        actual, translation = parser.status_from_lines(
          lines: lines,
          start_with: "Antigravity engines"
        )
        expect(actual).to be == "Online"
        expect(translation).to be == "Antigravitationsmotoren: Activ"
      end

      it "returns a status from an overloaded line" do
        lines = ["Antigravity engines: OVERLOADED|Antigravitationsmotoren: Überladen"]
        actual, translation = parser.status_from_lines(
          lines: lines,
          start_with: "Antigravity engines"
        )
        expect(actual).to be == "Overloaded"
        expect(translation).to be == "Antigravitationsmotoren: Überladen"
      end
    end

    context "engines" do
      it "returns a status from a 'ready' line" do
        lines = ["Warp engines: Ready to engage|Warp-Motoren: Bereit"]
        actual, translation = parser.status_from_lines(
          lines: lines,
          start_with: "Warp engines"
        )
        expect(actual).to be == "Ready"
        expect(translation).to be == "Warp-Motoren: Bereit"
      end

      it "returns a status from an charging  line" do
        lines = ["Warp engines: Charging ({charge}%)|Warp-Motoren: Laden ({charge}%)|charge=25"]
        actual, translation = parser.status_from_lines(
          lines: lines,
          start_with: "Warp engines"
        )
        expect(actual).to be == "Charging"
        expect(translation).to be == "Warp-Motoren: Laden (25%)"
      end
    end
  end
end
