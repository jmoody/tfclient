
module TFClient::DotDir

  def self.directory
    home = TFClient::Environment.user_home_directory
    dir = File.join(home, ".textflight", "client")
    if !File.exist?(dir)
      FileUtils.mkdir_p(dir)
    end
    dir
  end

  def self.local_database_file(dev:)
    if dev
      File.expand_path(File.join(self.directory,"development.db"))
    else
      File.expand_path(File.join(self.directory,"production.db"))
    end
  end
end

