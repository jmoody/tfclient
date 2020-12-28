
RSpec.describe TFClient::Models do

  let(:tmp_dir) { File.join("./", "tmp", "databases") }
  let(:all_pairs_fixture) do
    File.join("./", "spec", "fixtures", "databases", "all-pairs.db")
  end

  let(:all_pairs_db) do
    File.join(tmp_dir, "all-pairs.db")
  end

  before do
    FileUtils.mkdir_p(tmp_dir)
    FileUtils.rm_f(all_pairs_db)
    FileUtils.cp(all_pairs_fixture , all_pairs_db)
  end

  context "#system_for_coordinates" do

    it "can make a graph" do
      db = TFClient::Models::Local::Database.new(path: all_pairs_db)
      system = db.system_for_coordinates(x: 11, y: 20)

      puts system
      expect(system[:claimed_by]).to be == "nibiru"


    end

  end
end