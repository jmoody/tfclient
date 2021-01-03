
RSpec.describe TFClient::Models do
  let(:fixtures_dir) { File.join("spec", "fixtures", "responses") }
  let(:status_response) { File.read(File.join(fixtures_dir, "status.txt"))  }
  let(:lines) { status_response.lines(chomp: true)}

  context "StatusReport" do
    it "can create object from lines" do
      actual = TFClient::Models::Server::StatusReport.new(lines: lines)
      puts actual.hash[:name] = "ydoomj's Ship"
      puts actual.hash[:asteroid_type] = "ydoomj's Ship"
    end
  end
end