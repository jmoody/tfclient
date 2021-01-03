
RSpec.describe TFClient::FlightPlanner do

  before(:all) do
    tmp_dir = File.join("./", "tmp", "databases")
    all_pairs_db = File.join(tmp_dir, "all-pairs.db")

    FileUtils.mkdir_p(tmp_dir)
    FileUtils.rm_f(all_pairs_db)
    FileUtils.cp(
      File.join("./", "spec", "fixtures", "databases", "all-pairs.db"),
      all_pairs_db)
    TFClient::Models::Client::Database.connect(path: all_pairs_db)
  end

  let(:nibiru) do
    TFClient::Models::Client::System.find_by(system_id: "47244640276")
  end

  context "create the graph" do
    it "can create a graph" do
      graph = TFClient::FlightPlanner.create_graph
      expect(graph.rgl_graph.vertices.count).to be == 150
      expect(graph.rgl_graph.edges.count).to be == 212
      expect(graph.edge_weights.count).to be == 304
    end

    it "the flight planner can create a plan to an adjacent system" do
      nibiru = "47244640276"
      iron = "42949672980"

      directions = TFClient::FlightPlanner.new(source: nibiru,
                                               target: iron).plan
      expect(directions).to be == ["w"]

      directions = TFClient::FlightPlanner.new(source: iron,
                                               target: nibiru).plan

      expect(directions).to be == ["e"]
    end

    it "the flight planner can create a plan to a nearby system" do
      nibiru = "47244640276"
      carbon = "42949672978"
      directions = TFClient::FlightPlanner.new(source: nibiru,
                                               target: carbon).plan
      expect(directions).to be == ["sw", "s"]

      directions = TFClient::FlightPlanner.new(source: carbon,
                                               target: nibiru).plan

      expect(directions).to be == ["n", "ne"]
    end

    it "the flight planner can create a plan to a nearby system" do
      nibiru = "47244640276"
      uranium = "30064771091"
      directions = TFClient::FlightPlanner.new(source: nibiru,
                                               target: uranium).plan
      expect(directions).to be == ["sw", "s", "w", "w", "nw"]

      directions = TFClient::FlightPlanner.new(source: uranium,
                                               target: nibiru).plan

      expect(directions).to be == ["se", "e", "e", "n", "ne"]
    end

    it "the flight planner can create a plan to copper" do
      nibiru = "47244640276"
      copper = "47244640279"
      directions = TFClient::FlightPlanner.new(source: nibiru,
                                               target: copper).plan
      expect(directions).to be == ["nw", "n", "ne"]

      directions = TFClient::FlightPlanner.new(source: copper,
                                               target: nibiru).plan

      expect(directions).to be == ["sw", "s", "se"]
    end

    it "the flight planner can create a plan to 'greenhouse'" do
      nibiru = "47244640276"
      greenhouse = "30064771092"
      directions = TFClient::FlightPlanner.new(source: nibiru,
                                               target: greenhouse).plan
      expect(directions).to be == ["w", "nw", "s", "nw", "sw"]

      directions = TFClient::FlightPlanner.new(source: greenhouse,
                                               target: nibiru).plan

      expect(directions).to be == ["ne", "se", "n", "se", "e"]
    end

    it "the flight planner can create a plan to 'greenhouse'" do
      nibiru = "47244640276"
      greenhouse = "0"
      directions = TFClient::FlightPlanner.new(source: nibiru,
                                               target: greenhouse).plan
      expect(directions).to be == nil
    end
  end
end
