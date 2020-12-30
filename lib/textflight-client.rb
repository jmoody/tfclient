require "textflight-client/version"
require "textflight-client/logging"
require "textflight-client/environment"
require "textflight-client/dot_dir"
require "textflight-client/string_utils"
require "textflight-client/io"
require "textflight-client/setup"
require "textflight-client/dijkstra/dijkstra"
require "textflight-client/command_parser"
require "textflight-client/response_parser"
require "textflight-client/models/server/base_models"
require "textflight-client/models/server/nav"
require "textflight-client/models/server/scan"
require "textflight-client/models/server/status_report"
require "textflight-client/models/server/status"
require "textflight-client/models/local"
require "textflight-client/tfprompt"

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
