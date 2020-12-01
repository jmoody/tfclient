
module TFClient
  module StringUtils
    def self.remove_control_chars(string)
      string.gsub("\e[2J\e[H", "")
    end
  end
end