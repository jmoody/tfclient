
RSpec.describe TFClient::Models::Client::Coordinate do

  let(:coord) { described_class.new(x: 0, y: 0)}
  context ".coordinates_by_travelling" do
    it "returns the correct value for n" do
      actual = coord.coordinates_by_travelling(direction: "n")
      expect(actual).to be == described_class.new(x: 0, y: 1)
    end

    it "returns the correct value for ne" do
      actual = coord.coordinates_by_travelling(direction: "ne")
      expect(actual).to be == described_class.new(x: 1, y: 1)
    end

    it "returns the correct value for e" do
      actual = coord.coordinates_by_travelling(direction: "e")
      expect(actual).to be == described_class.new(x: 1, y: 0)
    end

    it "returns the correct value for se" do
      actual = coord.coordinates_by_travelling(direction: "se")
      expect(actual).to be == described_class.new(x: 1, y: -1)
    end

    it "returns the correct value for s" do
      actual = coord.coordinates_by_travelling(direction: "s")
      expect(actual).to be == described_class.new(x: 0, y: -1)
    end

    it "returns the correct value for sw" do
      actual = coord.coordinates_by_travelling(direction: "sw")
      expect(actual).to be == described_class.new(x: -1, y: -1)
    end

    it "returns the correct value for w" do
      actual = coord.coordinates_by_travelling(direction: "w")
      expect(actual).to be == described_class.new(x: -1, y: 0)
    end

    it "returns the correct value for nw" do
      actual = coord.coordinates_by_travelling(direction: "nw")
      expect(actual).to be == described_class.new(x: -1, y: 1)
    end
  end
end

RSpec.describe TFClient::Models::Client::System do

  before(:all) do
    tmp_dir = File.join("./", "tmp", "databases")
    all_pairs_db = File.join(tmp_dir, "all-pairs.db")

    FileUtils.mkdir_p(tmp_dir)
    FileUtils.rm_f(all_pairs_db)
    FileUtils.cp(
      File.join("./", "spec", "fixtures", "databases", "all-pairs.db"),
      all_pairs_db)
    TFClient::Models::Client::Database.connect(path: all_pairs_db)
  end

  let(:nibiru) do
    TFClient::Models::Client::System.find_by(system_id: "47244640276")
  end

  context "#links_array" do
    it "returns an Array of links" do
      expect(nibiru.links_array.count).to be == 7
    end
  end

  context "#system_in_direction" do
    it "returns a system in a given direction if it can be found in the db" do
      ne, _ = nibiru.system_in_direction(direction: "ne")
      expect(ne.system_id).to be == "51539607573"
      expect(ne.x).to be == 12
      expect(ne.y).to be == 21
    end

    it "returns nil if a system in a given direction cannot be found in the db" do
      n, coord = nibiru.system_in_direction(direction: "n")
      expect(n).to be == nil
      expect(coord.x).to be == 11
      expect(coord.y).to be == 21
    end
  end

  context "#connected_systems" do
    it "returns a list of connected systems from the db" do
      actual = nibiru.connected_systems
      expect(actual.length).to be == 7
      expect(actual[0].is_a?(TFClient::Models::Client::System)).to be == true
    end
  end

  context ".system_for_coordinate" do
    it "returns the system at coordinate if it can be found in the db" do
      coord = TFClient::Models::Client::Coordinate.new(x: 12, y: 21)
      ne = described_class.system_for_coordinate(coordinate: coord)
      expect(ne.system_id).to be == "51539607573"
    end

    it "returns nil if no system at coordinate can be found in the db" do
      coord = TFClient::Models::Client::Coordinate.new(x: 11, y: 21)
      n = described_class.system_for_coordinate(coordinate: coord)
      expect(n).to be == nil
    end
  end

  context ".create_system" do
    let(:fixtures_dir) { File.join("spec", "fixtures", "responses") }
    let(:nav_response) { File.read(File.join(fixtures_dir, "nav.txt"))  }
    let(:nav) do
      TFClient::Models::Server::Nav.new(lines: nav_response.lines(chomp: true))
    end

    it "can create a new system from status and nav" do
      actual = described_class.create_system(nav: nav,
                                             system_id: "2156")
      expect(actual.system_id).to be == "2156"
      expect(actual.x).to be == 1
      expect(actual.y).to be == 2
      expect(actual.claimed_by).to be == "nibiru"
      expect(actual.name).to be == "guertel"
      expect(actual.brightness).to be == 104
      expect(actual.asteroid_ore).to be == "carbon"
      expect(actual.asteroid_density).to be == 3

      expect(described_class.system_for_id(id: "2156")).to be_truthy
    end
  end
end
