
module TFClient
  module StringUtils

    # The server sends terminal control characters after login
    # These need to be removed
    def self.remove_terminal_control_chars(string:)
      string.gsub("\e[2J\e[H", "")
    end

    def self.remove_color_control_chars(string:)
      string.gsub(/\e\[([;\d]+)?m/, "")
    end
  end
end