RSpec.describe TFClient::StringUtils do

  context ".remove_control_chars" do
    it "returns a string with control characters removed" do
      # preserves whitespace and newlines
      string = " abc \n def\n"
      expect(described_class.remove_control_chars(string)).to be == string

      string = " abc\\e[2J\\e[H\n def\n"
      expected = " abc\n def\n"
      expect(described_class.remove_control_chars(string)).to be == expected
    end
  end
end
