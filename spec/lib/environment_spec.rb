
RSpec.describe TFClient::Environment do

  let(:environment) { TFClient::Environment.new }

  describe ".user_home_directory" do
    it "always returns a directory that exists" do
      expect(File.exist?(TFClient::Environment.user_home_directory)).to be_truthy
    end
  end

  describe ".windows_env?" do
    before do
      TFClient::Environment.class_variable_set(:@@windows_env, nil)
    end

    it "returns the value of @@windows_env if it is non-nil" do
      TFClient::Environment.class_variable_set(:@@windows_env, :windows)

      expect(TFClient::Environment.windows_env?).to be_truthy
      expect(TFClient::Environment.class_variable_get(:@@windows_env)).to be_truthy
    end

    describe "matches 'host_os' against known windows hosts" do
      it "true" do
        expect(TFClient::Environment).to receive(:host_os_is_win?).and_return(true)

        expect(TFClient::Environment.windows_env?).to be_truthy
        expect(TFClient::Environment.class_variable_get(:@@windows_env)).to be == true
      end

      it "false" do
        expect(TFClient::Environment).to receive(:host_os_is_win?).and_return(false)

        expect(TFClient::Environment.windows_env?).to be_falsey
        expect(TFClient::Environment.class_variable_get(:@@windows_env)).to be == false
      end
    end
  end

  describe '.debug?' do
    it "returns true when DEBUG == '1'" do
      stub_env('DEBUG', '1')
      expect(TFClient::Environment.debug?).to be == true
    end

    it "returns false when DEBUG != '1'" do
      stub_env('DEBUG', 1)
      expect(TFClient::Environment.debug?).to be == false
    end
  end
end

