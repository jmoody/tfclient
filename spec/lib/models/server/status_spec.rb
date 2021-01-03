
RSpec.describe TFClient::Models::Server::Status do
  let(:fixtures_dir) { File.join("spec", "fixtures", "responses") }
  let(:status_response) { File.read(File.join(fixtures_dir, "status.txt"))  }
  let(:lines) { status_response.lines(chomp: true)}


  let(:status) { TFClient::Models::Server::Status.new(lines: lines) }

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
    expect(status.warp_charge).to be == 44.0
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

