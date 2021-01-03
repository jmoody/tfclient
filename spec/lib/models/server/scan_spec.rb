
RSpec.describe TFClient::Models do
  let(:fixtures_dir) { File.join("spec", "fixtures", "responses") }
  let(:scan_response) { File.read(File.join(fixtures_dir, "scan.txt"))  }
  let(:lines) { scan_response.lines(chomp: true)}

  context "Scan" do
    context ".new" do
      it "returns an instance from list of lines" do
        actual = TFClient::Models::Server::Scan.new(lines: lines)
        expect(actual.id).to be == 1
        expect(actual.name).to be == "abc's Ship"
        expect(actual.owner.username).to be == "abc"
        expect(actual.outfit_space.value).to be == 8

        puts actual.response
      end
     end
  end

  context "Owner" do

  end

  context "Operators" do

  end

  context "OutfitSpace" do
    context ".slots_used" do
      it "returns the number of outfit slots used" do
        actual = TFClient::Models::Server::Outfits.new(lines: lines)
        expect(actual.slots_used).to be == 29
      end
    end
  end

  context "ShieldCharge" do

  end

  context "Outfits" do

  end

  context "Cargo" do

  end
end
