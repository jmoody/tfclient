
module TFClient

  # cyan
  def self.log_unix_cmd(msg)
    if ENV["DEBUG"] == "1"
      puts Color.cyan("SHELL: #{msg}") if msg
    end
  end

  # blue
  def self.warn(msg)
    puts Color.blue(" WARN: #{msg}") if msg
  end

  # magenta
  def self.debug(msg)
    if ENV["DEBUG"] == "1"
      puts Color.magenta("DEBUG: #{msg}") if msg
    end
  end

  # green
  def self.info(msg)
    puts Color.green(" INFO: #{msg}") if msg
  end

  # red
  def self.error(msg)
    puts Color.red("ERROR: #{msg}") if msg
  end

  module Color
    def self.colorize(string, color)
      "\033[#{color}m#{string}\033[0m"
    end

    def self.red(string)
      colorize(string, 31)
    end

    def self.blue(string)
      colorize(string, 34)
    end

    def self.magenta(string)
      colorize(string, 35)
    end

    def self.cyan(string)
      colorize(string, 36)
    end

    def self.green(string)
      colorize(string, 32)
    end
  end
end
