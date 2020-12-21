
RSpec.describe TFClient::DotDir do

  let(:home_dir) { "./tmp/dot_dir_examples" }
  let(:dot_dir) { File.join(home_dir, ".textflight", "client") }

  before do
    allow(TFClient::Environment).to receive(:user_home_directory).and_return home_dir
    FileUtils.rm_rf(home_dir)
  end

  it ".directory" do
    path = TFClient::DotDir.directory

    expect(File.exist?(path)).to be_truthy
  end
end

