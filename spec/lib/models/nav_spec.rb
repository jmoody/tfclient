
RSpec.describe TFClient::Models do
  let(:fixtures_dir) { File.join("spec", "fixtures", "responses") }
  let(:scan_response) { File.read(File.join(fixtures_dir, "nav.txt"))  }
  let(:lines) { scan_response.lines(chomp: true)}

  context "Nav" do
    it ".new" do
      actual = TFClient::Models::Nav.new(lines: lines)

      expect(actual.coordinates.to_s).to be == "Koordinaten: (1,2)"
      expect(actual.claimed_by.faction).to be == "nibiru"
      expect(actual.brightness.value).to be == 104
      puts actual
    end
  end

  context "Coordinates" do
    it ".new can return a valid object from a line" do
      line, _= TFClient::ResponseParser.line_and_index_for_label(lines: lines,
                                                                 label: "Coordinates")
      actual = TFClient::Models::Coordinates.new(line: line)
      expect(actual.label).to be == "Coordinates"
      expect(actual.translation).to be == "Koordinaten"
      expect(actual.x).to be == 1
      expect(actual.y).to be == 2

      expect(actual.to_s).to be == "Koordinaten: (1,2)"
    end
  end

  context "ClaimedBy" do
    it ".new can return a valid object from a line" do
      line, _= TFClient::ResponseParser.line_and_index_for_label(lines: lines,
                                                                 label: "Claimed by")
      actual = TFClient::Models::ClaimedBy.new(line: line)
      expect(actual.label).to be == "Claimed by"
      expect(actual.translation).to be == "Beansprucht von"
      expect(actual.faction).to be == "nibiru"

      expect(actual.to_s).to be == "Beansprucht von 'nibiru'"
    end
  end

  context "Brightness" do
    it ".new can return a valid object from a  line" do
      line, _= TFClient::ResponseParser.line_and_index_for_label(lines: lines,
                                                                 label: "Brightness")
      actual = TFClient::Models::Brightness.new(line: line)
      expect(actual.label).to be == "Brightness"
      expect(actual.translation).to be == "Helligkeit"
      expect(actual.value).to be == 104
      expect(actual.percent).to be == 41

      expect(actual.to_s).to be == "Helligkeit: 104 => 41%"
    end
  end

  context "Asteroid" do
    it ".new can return a valid object from a line" do
      line, _= TFClient::ResponseParser.line_and_index_for_label(lines: lines,
                                                                 label: "Asteroids")
      actual = TFClient::Models::Asteroids.new(line: line)
      expect(actual.label).to be == "Asteroids"
      expect(actual.translation).to be == "Ästeroiden"
      expect(actual.ore).to be == "carbon"
      expect(actual.density).to be == 3
      expect(actual.percent).to be == 43
      expect(actual.to_s).to be == "Ästeroiden: carbon (3) => 43%"
    end
  end

  context "Links" do
    it ".new can return a valid object from a list of lines" do
      actual = TFClient::Models::Links.new(lines: lines)
      expect(actual.label).to be == "Links"
      expect(actual.translation).to be == "Ausfahrten"
      expect(actual.count).to be == 4

      expect(actual.items[0][:drag]).to be == 51
      expect(actual.items[0][:index]).to be == 7
      expect(actual.items[0][:faction]).to be == nil
      expect(actual.items[0][:direction]).to be == "ne"

      expect(actual.items[1][:drag]).to be == 32
      expect(actual.items[1][:index]).to be == 4
      expect(actual.items[1][:faction]).to be == nil
      expect(actual.items[1][:direction]).to be == "e"

      expect(actual.items[2][:drag]).to be == 170
      expect(actual.items[2][:index]).to be == 0
      expect(actual.items[2][:faction]).to be == nil
      expect(actual.items[2][:direction]).to be == "sw"

      expect(actual.items[3][:drag]).to be == 90
      expect(actual.items[3][:index]).to be == 5
      expect(actual.items[3][:faction]).to be == "nibiru"
      expect(actual.items[3][:direction]).to be == "nw"

      puts actual
    end
  end

  context "Planets" do
    it ".new can return a valid object from a list of lines" do
      actual = TFClient::Models::Planets.new(lines: lines)

      expect(actual.label).to be == "Planets"
      expect(actual.translation).to be == "Planeten"
      expect(actual.count).to be == 4

      expect(actual.items[0][:index]).to be == 0
      expect(actual.items[0][:type]).to be == "GAS"
      expect(actual.items[0][:name]).to be == nil
      expect(actual.items[0][:faction]).to be == nil

      expect(actual.items[1][:index]).to be == 1
      expect(actual.items[1][:type]).to be == "Frozen"
      expect(actual.items[1][:name]).to be == nil
      expect(actual.items[1][:faction]).to be == nil

      expect(actual.items[2][:index]).to be == 6
      expect(actual.items[2][:type]).to be == "Habitable"
      expect(actual.items[2][:name]).to be == "notwendig"
      expect(actual.items[2][:faction]).to be == "nibiru"

      expect(actual.items[3][:index]).to be == 2
      expect(actual.items[3][:type]).to be == "Barren"
      expect(actual.items[3][:name]).to be == nil
      expect(actual.items[3][:faction]).to be == nil
      puts actual
    end
  end

  context "Structures" do
    it ".new can return a valid object from a list of lines" do
      actual = TFClient::Models::Structures.new(lines: lines)

      expect(actual.label).to be == "Structures"
      expect(actual.translation).to be == "Strukturen"
      expect(actual.count).to be == 4

      expect(actual.items[0][:id]).to be == 123
      expect(actual.items[0][:name]).to be == "abc's Ship"
      expect(actual.items[0][:type]).to be == "AST"

      expect(actual.items[1][:id]).to be == 456
      expect(actual.items[1][:name]).to be == "Moonlight on Window"
      expect(actual.items[1][:type]).to be == "GAX"

      expect(actual.items[2][:id]).to be == 789
      expect(actual.items[2][:name]).to be == "Consider Phlebus"
      expect(actual.items[2][:type]).to be == "SAT"

      expect(actual.items[3][:id]).to be == 360
      expect(actual.items[3][:name]).to be == "hafen-9"
      expect(actual.items[3][:type]).to be == nil

      puts actual
    end
  end
end
