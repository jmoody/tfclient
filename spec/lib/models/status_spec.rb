
RSpec.describe TFClient::Models do
  let(:fixtures_dir) { File.join("spec", "fixtures", "responses") }
  let(:status_response) { File.read(File.join(fixtures_dir, "status.txt"))  }
  let(:lines) { status_response.lines(chomp: true)}

  context "Status" do

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

