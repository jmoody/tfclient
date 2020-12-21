
module TFClient
  class Environment

    # Returns the user home directory
    def self.user_home_directory
      require 'etc'
      # If uid is omitted, the value from Passwd[:uid] is returned instead.
      #noinspection RubyArgCount
      Etc.getpwuid.dir
    end

    # Returns true if Windows environment
    def self.windows_env?
      if @@windows_env.nil?
        @@windows_env = Environment.host_os_is_win?
      end

      @@windows_env
    end

    # Returns true if debugging is enabled.
    def self.debug?
      ENV['DEBUG'] == '1'
    end

    private

    # !@visibility private
    def self.ci_var_defined?
      value = ENV["CI"]
      !!value && value != ''
    end


    # @visibility private
    WIN_PATTERNS = [
      /bccwin/i,
      /cygwin/i,
      /djgpp/i,
      /mingw/i,
      /mswin/i,
      /wince/i,
    ]

    # @!visibility private
    @@windows_env = nil

    # @!visibility private
    def self.host_os_is_win?
      ruby_platform = RbConfig::CONFIG["host_os"]
      !!WIN_PATTERNS.find { |r| ruby_platform =~ r }
    end
  end
end
