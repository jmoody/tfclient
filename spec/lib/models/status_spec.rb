
RSpec.describe TFClient::Models::Status do
  let(:fixtures_dir) { File.join("spec", "fixtures", "responses") }
  let(:status_response) { File.read(File.join(fixtures_dir, "status.txt"))  }
  let(:lines) { status_response.lines(chomp: true)}


  context ".cooling_status_from_line" do
    it "returns a status from a stable line" do
      line = "	Cooling status: Stable| Cooling status: Stabil"
      actual = described_class.cooling_status_from_line(line: line)
      expect(actual).to be == "Stabil"
    end

    it "returns a status from an overheated line" do
      line = "	Cooling status: OVERHEATED|     Cooling status: Überhitzt"
      actual = described_class.cooling_status_from_line(line: line)
      expect(actual).to be == "Überhitzt"
    end

    it "returns a status from an overheating in N seconds line" do
      line = "	Cooling status: Overheat in {remaining} seconds!|       Cooling status: Überhitzung in {remaining} Sekunden!|remaining=46"
      actual = described_class.cooling_status_from_line(line: line)
      expect(actual).to be == "Überhitzung in 46 Sekunden!"
    end
  end

  let(:status) { TFClient::Models::Status.new(lines: lines) }

  it "returns information from the 'General' section" do
    expect(status.mass).to be == 26
    expect(status.total_outfit_space).to be == 8
    expect(status.used_outfit_space).to be == 6

    expect(status.heat).to be == 11
    expect(status.max_heat).to be == 60
    expect(status.heat_rate).to be == -3.0
  end


  context "General" do

  end

  context "Stability" do

  end

  context "Shields" do

  end

  context "WarpEngines" do

  end
end

