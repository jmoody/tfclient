
RSpec.describe TFClient::Models::Status do
  let(:fixtures_dir) { File.join("spec", "fixtures", "responses") }
  let(:status_response) { File.read(File.join(fixtures_dir, "status.txt"))  }
  let(:lines) { status_response.lines(chomp: true)}


  context ".cooling_status_from_line" do
    it "returns a status from a stable line" do
      lines = ["	Cooling status: Stable| Kühlstatus: Stabil"]
      actual = described_class.status_from_lines(lines: lines,
                                                 start_with: "Cooling status")
      expect(actual).to be == "Kühlstatus: Stabil"
    end

    it "returns a status from an overheated line" do
      lines = ["	Cooling status: OVERHEATED|     Kühlstatus: Überhitzt"]
      actual = described_class.status_from_lines(lines: lines,
                                                 start_with: "Cooling status")
      expect(actual).to be == "Kühlstatus: Überhitzt"
    end

    it "returns a status from an overheating in N seconds line" do
      lines = ["	Cooling status: Overheat in {remaining} seconds!|       Cooling status: Überhitzung in {remaining} Sekunden!|remaining=46"]
      actual = described_class.status_from_lines(lines: lines,
                                                 start_with: "Cooling status")
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
    expect(status.cooling_status).to be == "Kühlstatus: Stabil"

    expect(status.energy).to be == 22
    expect(status.max_energy).to be == 120
    expect(status.energy_rate).to be == 5.0
  end

  it "returns antigravity engine information" do
    expect(status.antigravity_engine_status).to be == "Antigravitationsmotoren: Activ"
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

