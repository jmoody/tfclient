
module TFClient
  module StringUtils
    TERM_CONTROL_REGEX = /\\e([^\[\]]|\[.*?[a-zA-Z]|\].*?\a)/.freeze

    def self.remove_control_chars(string)
      string.gsub(TERM_CONTROL_REGEX, "")
    end
  end
end