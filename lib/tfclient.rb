require "tfclient/version"
require "tfclient/logging"
require "tfclient/environment"
require "tfclient/dot_dir"
require "tfclient/string_utils"
require "tfclient/command_parser"
require "tfclient/response_parser"
require "tfclient/models/model"
require "tfclient/models/nav"
require "tfclient/models/scan"
require "tfclient/models/status_report"
require "tfclient/models/status"
require "tfclient/models/local"
require "tfclient/tfprompt"

module TFClient

  # Prints a deprecated message that includes the line number.
  #
  # @param [String] version Indicates when the feature was deprecated.
  # @param [String] msg Deprecation message (possibly suggesting alternatives)
  # @return [void]
  def self.deprecated(version, msg)

    stack = Kernel.caller(0, 6)[1..-1].join("\n")

    msg = "deprecated '#{version}' - #{msg}\n#{stack}"

    $stderr.puts "\033[34mWARN: #{msg}\033[0m"
    $stderr.flush
  end

end
