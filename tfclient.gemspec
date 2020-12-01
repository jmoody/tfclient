# -*- encoding: utf-8 -*-

Gem::Specification.new do |spec|
  spec.name          = "tfclient"
  spec.version       =  begin
    file = "#{File.expand_path(File.join(__dir__, "lib", "tfclient", "version.rb"))}"
    m = Module.new
    m.module_eval IO.read(file).force_encoding("utf-8")
    version = m::TFClient::VERSION
    unless /(\d+\.\d+\.\d+(\.pre\d+)?)/.match(version)
      raise %Q{
Could not parse constant TFClient::VERSION: "#{version}"
into a valid version, e.g. 1.2.3 or 1.2.3.pre10
}
    end
    version
  end
  spec.authors       = ["Joshua Moody"]
  spec.email         = ["jmoody@github.com"]

  spec.summary       = %q{A command-line client for the TextFlight.}
  spec.description   = %q{TextFlight is a space-based text adventure MMO.

https://leagueh.xyz/tf/
https://leagueh.xyz/git/textflight/

}

  spec.homepage      = "https://github.com/jmoody/tfclient"
  spec.license       = "GPLv3"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7")

  spec.metadata["allowed_push_host"] = "https://rubygemspec.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/jmoody/tfclient/blob/develop/CHANGELOG.md"

  spec.files = [
    Dir.glob("{lib}/**/*.rb"),
    Dir.glob("scripts/**/*.sh"),
    Dir.glob("{bin}/**/*"),
    "Gemfile", "Rakefile", "README.md", "LICENSE.md", "CHANGELOG.md"
  ].flatten

  spec.bindir        = "bin"
  spec.executables   = ["client.rb"]
  spec.require_paths = ["lib"]

  spec.add_dependency("json")
  spec.add_development_dependency("awesome_print", "~> 1.8")
  spec.add_development_dependency("bundler", "~> 2.1")
  spec.add_development_dependency("rspec", "~> 3.10")
  spec.add_development_dependency("rake", "~> 13.0")
  spec.add_development_dependency("guard-rspec", "~> 4.0")
  spec.add_development_dependency("terminal-notifier", "~> 2.0")
  spec.add_development_dependency("terminal-notifier-guard", "~> 1.0")
  spec.add_development_dependency("guard-bundler", "~> 3.0")
  spec.add_development_dependency("stub_env", ">= 1.0.4", "< 2.0")
  spec.add_development_dependency("pry", "~> 0.13")
  spec.add_development_dependency("irb", "~> 1.2")
  spec.add_development_dependency("bundler-audit", "~> 0.7")
end
