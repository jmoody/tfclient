
module TFClient
  class ResponseParser

    attr_reader :command
    attr_reader :textflight_command
    attr_reader :response
    attr_reader :lines

    def initialize(command:, textflight_command:, response:)
      @command = command
      @textflight_command = textflight_command
      @response = response
    end

    def parse
      @lines = @response.lines(chomp: true).reject { |line| line.length == 0 }
      case @textflight_command
      when "nav"
        parse_nav(command: @command)
      when "scan"
        parse_scan
      when "status"
        parse_status(command: @command)
      else
        echo_response(command: @command)
      end
    end

    def echo_response(command:)
      if @response[/#{TFClient::Models::Server::STATUS_BEGIN}/]
        TFClient.info("Received STATUS REPORT response")
        return parse_status(command: command)
      end

      parser = Class.new do
        include TFClient::Models::Server::Parser
      end.new

      puts parser.substitute_values(lines: @lines).join("\n")
    end

    def parse_nav(command:)
      nav = TFClient::Models::Server::Nav.new(lines: lines)
      if command != "nav-for-prompt"
        puts nav.response
      end
      nav
    end

    def parse_scan
      scan = TFClient::Models::Server::Scan.new(lines: lines)
      puts scan.response
      scan
    end

    def parse_status(command:)
      status = TFClient::Models::Server::Status.new(lines: lines)
      if command == "status-for-prompt"
        status
      else
        lines_to_print, _ =
          Models::Server::Parser.process_status_report_response(lines: lines)
        puts lines_to_print.join("\n")
        status
      end
    end
  end
end