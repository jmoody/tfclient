
RSpec.describe TFClient::Models::Client::Database do
  let(:tmp_dir) { File.join("./", "tmp", "databases") }
  let(:all_pairs_db) { File.join(tmp_dir, "all-pairs.db") }

  before do
    FileUtils.mkdir_p(tmp_dir)
    FileUtils.rm_f(all_pairs_db)
    FileUtils.cp(
      File.join("./", "spec", "fixtures", "databases", "all-pairs.db"),
      all_pairs_db)
  end

  context ".connect" do
    it "can connect to the db at path" do
      described_class.connect(path: all_pairs_db)
      sys = TFClient::Models::Client::System.find_by(system_id: "47244640276")
      expect(sys.links_array.count).to be == 7
    end
  end
end