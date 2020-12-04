
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
end

