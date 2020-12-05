
RSpec.describe TFClient::Models do
  let(:fixtures_dir) { File.join("spec", "fixtures", "responses") }
  let(:scan_response) { File.read(File.join(fixtures_dir, "nav.txt"))  }
  let(:lines) { scan_response.lines(chomp: true)}

  context "Coordinate" do
    it ".new can return a valid object from a array of tokens" do
      tokens = TFClient::ResponseParser.tokenize_line(line: lines[0])
      actual = TFClient::Models::Coordinate.new(tokens: tokens)
      expect(actual.label).to be == "Coordinates"
      expect(actual.translation).to be == "Koordinaten"
      expect(actual.x).to be == 1
      expect(actual.y).to be == 2

      expect(actual.to_s).to be == "Koordinaten: 1,2"
    end
  end

  context "Brightness" do
    it ".new can return a valid object from a array of tokens" do
      # Brightness: {brightness}|Helligkeit: {brightness}|brightness=104
      tokens = TFClient::ResponseParser.tokenize_line(line: lines[1])
      actual = TFClient::Models::Brightness.new(tokens: tokens)
      expect(actual.label).to be == "Brightness"
      expect(actual.translation).to be == "Helligkeit"
      expect(actual.brightness).to be == 104
      expect(actual.percent).to be == 41

      expect(actual.to_s).to be == "Helligkeit: 104 => 41%"
    end
  end

  context "Asteroid" do
    it ".new can return a valid object from a array of tokens" do
      # Asteroids: {asteroid_type} (density: {asteroid_density})|\
      # Ästeroiden: {asteroid_type} (density: {asteroid_density})|\
      # asteroid_type=carbon|asteroid_density=3
      tokens = TFClient::ResponseParser.tokenize_line(line: lines[2])
      actual = TFClient::Models::Asteroids.new(tokens: tokens)
      expect(actual.label).to be == "Asteroids"
      expect(actual.translation).to be == "Ästeroiden"
      expect(actual.ore).to be == "carbon"
      expect(actual.density).to be == 3
      expect(actual.percent).to be == 43
      expect(actual.to_s).to be == "Ästeroiden: carbon (3) => 43%"
    end
  end

  context "Links" do
    it ".new can return a valid object from lines and a links index" do
      actual = TFClient::Models::Links.new(lines: lines, links_index: 3)
      expect(actual.label).to be == "Links"
      expect(actual.translation).to be == "Ausfahrten"
      expect(actual.links.length).to be == 3
      expect(actual.links[0][:drag]).to be == 170
      expect(actual.links[0][:index]).to be == 0
      expect(actual.links[1][:drag]).to be == 32
      expect(actual.links[1][:index]).to be == 4
      expect(actual.links[2][:drag]).to be == 51
      expect(actual.links[2][:index]).to be == 7
    end
  end

  context "Planets" do
    it ".new can return a valid object from lines and a links index" do
      actual = TFClient::Models::Planets.new(lines: lines, links_index: 7)
      expect(actual.label).to be == "Planets"
      expect(actual.translation).to be == "Planeten"
      expect(actual.planets.length).to be == 3
      expect(actual.planets[0][:index]).to be == 0
      expect(actual.planets[0][:type]).to be == "GAS"
      expect(actual.planets[1][:index]).to be == 1
      expect(actual.planets[1][:type]).to be == "Frozen"
      expect(actual.planets[2][:index]).to be == 2
      expect(actual.planets[2][:type]).to be == "Barren"
    end
  end
end

