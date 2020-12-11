
RSpec.describe TFClient::Models do
  let(:fixtures_dir) { File.join("spec", "fixtures", "responses") }
  let(:scan_response) { File.read(File.join(fixtures_dir, "scan.txt"))  }
  let(:lines) { scan_response.lines(chomp: true)}

  context "Scan" do
    context ".new" do
      it "returns an instance from list of lines" do
        actual = TFClient::Models::Scan.new(lines: lines)

        expect(actual.id).to be == 1
        expect(actual.name).to be == "abc's Ship"
      end
     end
  end

  context "Owner" do

  end

  context "Operators" do

  end

  context "OutfitSpace" do

  end

  context "ShieldCharge" do

  end

  context "Outfits" do

  end

  context "Cargo" do

  end
end
