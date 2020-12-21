
RSpec.describe TFClient::Models::Status do
  let(:fixtures_dir) { File.join("spec", "fixtures", "responses") }
  let(:status_response) { File.read(File.join(fixtures_dir, "status.txt"))  }
  let(:lines) { status_response.lines(chomp: true)}


  context ".status_from_line" do
    context "cooling" do
      it "returns a status from a stable line" do
        lines = ["	Cooling status: Stable| Kühlstatus: Stabil"]
        actual, translation = described_class.status_from_lines(
          lines: lines,
          start_with: "Cooling status"
        )
        expect(actual).to be == "Stable"
        expect(translation).to be == "Kühlstatus: Stabil"
      end

      it "returns a status from an overheated line" do
        lines = ["	Cooling status: OVERHEATED|     Kühlstatus: Überhitzt"]
        actual, translation = described_class.status_from_lines(
          lines: lines,
          start_with: "Cooling status"
        )
        expect(actual).to be == "Overheated"
        expect(translation).to be == "Kühlstatus: Überhitzt"
      end

      it "returns a status from an overheating in N seconds line" do
        lines = ["	Cooling status: Overheat in {remaining} seconds!|       Kühlstatus: Überhitzung in {remaining} Sekunden!|remaining=46"]
        actual, translation = described_class.status_from_lines(
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
        actual, translation = described_class.status_from_lines(
          lines: lines,
          start_with: "Power status"
        )
        expect(actual).to be == "Stable"
        expect(translation).to be == "Stromstatus: Stabil"
      end

      it "returns a status from a brown line" do
        lines = [" Power status: BROWNOUT| Stromstatus: Stromausfall" ]
        actual, translation = described_class.status_from_lines(
          lines: lines,
          start_with: "Power status"
        )
        expect(actual).to be == "Brownout"
        expect(translation).to be == "Stromstatus: Stromausfall"
      end

      it "returns a status from an overheating in N seconds line" do
        lines = [ 	"Power status: Brownout in {remaining} seconds!| Stromstatus: Stromausfall in {remaining} Sekunden!|remaining=11"]
        actual, translation = described_class.status_from_lines(
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
        actual, translation = described_class.status_from_lines(
          lines: lines,
          start_with: "Warp engines"
        )
        expect(actual).to be == "Ready"
        expect(translation).to be == "Warp-Motoren: Bereit zum Einschalten"
      end

      it "returns a status from a recharging line" do
        lines = ["  Warp engines: Charging ({charge}%)|Warp-Motoren: Aufladen ({charge}%)|charge=97"]
        actual, translation = described_class.status_from_lines(
          lines: lines,
          start_with: "Warp engines"
        )
        expect(actual).to be == "Charging"
        expect(translation).to be == "Warp-Motoren: Aufladen (97%)"
      end

      it "returns a status from a offline line" do
        lines = [ "Warp engines: Offline|Warp-Motoren: Offline" ]
        actual, translation = described_class.status_from_lines(
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
        actual, translation = described_class.status_from_lines(
          lines: lines,
          start_with: "Shields"
        )
        expect(actual).to be == "Online"
        expect(translation).to be == "Schilde: Bereit"
      end

      it "returns a status from a failed line" do
        lines = ["	Shields: FAILED|Schilde: Gescheitert" ]
        actual, translation = described_class.status_from_lines(
          lines: lines,
          start_with: "Shields"
        )
        expect(actual).to be == "Failed"
        expect(translation).to be == "Schilde: Gescheitert"
      end

      it "returns status from a regenerating line" do
        lines = ["Shields: Regenerating at {rate}/s ({shield}/{max})|Schilde: Regenerieren bei {rate}/s ({shield}/{max})|shield=24|max=60|rate=0.2"]
        actual, translation = described_class.status_from_lines(
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
        actual, translation = described_class.status_from_lines(
          lines: lines,
          start_with: "Antigravity engines"
        )
        expect(actual).to be == "Online"
        expect(translation).to be == "Antigravitationsmotoren: Activ"
      end

      it "returns a status from an overloaded line" do
        lines = ["Antigravity engines: OVERLOADED|Antigravitationsmotoren: Überladen"]
        actual, translation = described_class.status_from_lines(
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
        actual, translation = described_class.status_from_lines(
          lines: lines,
          start_with: "Warp engines"
        )
        expect(actual).to be == "Ready"
        expect(translation).to be == "Warp-Motoren: Bereit"
      end

      it "returns a status from an charging  line" do
        lines = ["Warp engines: Charging ({charge}%)|Warp-Motoren: Laden ({charge}%)|charge=25"]
        actual, translation = described_class.status_from_lines(
          lines: lines,
          start_with: "Warp engines"
        )
        expect(actual).to be == "Charging"
        expect(translation).to be == "Warp-Motoren: Laden (25%)"
      end
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
    expect(status.states[:cooling]).to be == "Stable"

    expect(status.energy).to be == 22
    expect(status.max_energy).to be == 120
    expect(status.energy_rate).to be == 5.0
    expect(status.power_status).to be == "Stromstatus: Stabil"
    expect(status.states[:power]).to be == "Stable"
  end

  it "returns antigravity engine information" do
    expect(status.antigravity_engine_status).to be == "Antigravitationsmotoren: Activ"
    expect(status.antigravity).to be == 256
    expect(status.states[:antigravity]).to be == "Online"
  end

  it "returns mining information" do
    expect(status.mining_status).to be == "Bergbaufortschritt: 22% (560.0 Sekundenintervalle)"
    expect(status.mining_interval).to be == 560.0
    expect(status.mining_power).to be == 1.0
    expect(status.states[:mining]).to be == "Online"
  end

  it "returns engine information" do
    expect(status.engine_status).to be == "Warp-Motoren: Laden (25%)"
    expect(status.engine_charge).to be == 44.0
    expect(status.states[:warp]).to be == "Charging"
  end

  it "returns shield information" do
    expect(status.shield_status).to be == "Schilde: Regenerieren bei 0.2/s (24/60)"
    expect(status.shield_charge_rate).to be == 0.5
    expect(status.shield_max).to be == 60.0
    expect(status.shield).to be == 33.0
    expect(status.states[:shields]).to be == "Regenerating"
  end

  it "returns colonist information" do
    expect(status.colonists).to be == 512
    expect(status.colonists_status).to be == "Kolonisten: 512"
    expect(status.states[:colonists]).to be == "Crewed"
  end
end

