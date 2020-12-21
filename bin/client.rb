#!/usr/bin/env ruby

module TextFlight
  require "openssl"
  require "socket"
  require "readline"
  require "pry"

  class CLI

    def self.write_command(socket:, command:)
      timeout = 5.0
      ready = IO.select(nil, [socket], nil, timeout)

      if !ready
        message = "Timed out waiting for socket to be ready for writes after #{timeout} seconds"
        socket.close
        raise message
      end

      begin
        socket.puts(command)
      rescue StandardError, IOError => e
        message = <<~EOM
          Caught error while writing to socket

          #{e.message}

          after reading #{buffer.bytesize} from socket:

          #{buffer}
        EOM
        socket.close
        raise(e.class, message)
      end
    end

    def self.read_response(socket:)
      timeout = 5.0
      ready = IO.select([socket], nil, nil, timeout)

      if !ready
        message = "Timed out waiting for socket to response after #{timeout} seconds"
        socket.close
        raise message
      end

      buffer = ""
      max_tries = 3
      tries = 1
      begin
        loop do
          response = socket.read_nonblock(4096, exception: false)

          if response == :wait_readable
            if tries < max_tries
              TFClient.debug(
                "received :wait_readable on try: #{tries} of #{max_tries}; retrying"
              )
              tries = tries + 1
              sleep(0.2)
              next
            else
              TFClient.debug(
                "received :wait_readable on try: #{tries} of #{max_tries}; breaking"
              )
              # could be we have to exit here
              break
            end
          elsif response == nil
            TFClient.error(
              "received 'nil' on try: #{tries} of #{max_tries}; exiting"
            )
            raise("Server returned nil, possibly because of rate limiting")
          end

          TFClient.debug(
            "received #{response.bytesize} bytes; pushing onto buffer"
          )
          tries = 1
          response.delete_prefix!("> ")
          response.delete_suffix!("> ")
          response = TFClient::StringUtils.remove_terminal_control_chars(string: response)
          response = TFClient::StringUtils.remove_color_control_chars(string: response)
          buffer = buffer + response

          sleep(0.2)
        end
      rescue StandardError, IOError => e
        message = <<~EOM
          Caught error while reading from socket:

          #{e.message}

          after reading #{buffer.bytesize} bytes from socket:

          #{buffer}
        EOM
        socket.close
        raise(e.class, message)
      end

      buffer

      #buffer.lines(chomp:true)
    end

    def self.parse_response(response:)
      response.each do |line|
        puts "#{line}"
      end
    end

    def self.register(socket:, user:, pass:)
      TFClient.debug("=== REGISTER ===")
      TFClient.info("registering user: #{user} pass: #{pass[0..3]}***")
      sleep(0.5)
      self.write_command(socket: socket, command: "register #{user} #{pass}")

      response = self.read_response(socket: socket)
      puts response
    end

    def self.login(socket:, user:, pass:)
      TFClient.debug("=== LOGIN ===")
      TFClient.info("logging in user: #{user} pass: #{pass[0..3]}***")
      sleep(0.5)
      self.write_command(socket: socket, command: "login #{user} #{pass}")

      response = self.read_response(socket: socket)
      lines = response.lines(chomp: true)
      if lines[0] && lines[0].chomp == "Incorrect username or password."
        TFClient.error("#{response[0].chomp}")
        socket.close
        exit(1)
      end
    end

    def self.enable_client_mode(socket:)
      TFClient.debug("=== ENABLE CLIENT MODE ===")
      sleep(0.5)
      self.write_command(socket: socket, command: "language client")
      response = self.read_response(socket: socket)
      puts response
    end

    def self.status(socket:)
      sleep(0.5)
      TextFlight::CLI.write_command(socket: socket, command: "status")
      sleep(0.5)
      response = TextFlight::CLI.read_response(socket: socket)
      TFClient::ResponseParser.new(command: "status",
                                   textflight_command: "status",
                                   response: response).parse
    end

    def self.nav(socket: @socket)
      sleep(0.5)
      TextFlight::CLI.write_command(socket: socket, command: "nav")
      sleep(0.5)
      response = TextFlight::CLI.read_response(socket: socket)
      TFClient::ResponseParser.new(command: "nav",
                                   textflight_command: "nav",
                                   response: response).parse
    end

    attr_reader :socket, :user, :pass, :host, :port, :tcp, :state, :dev

    def initialize(host:, port:, tcp:, user:, pass:, dev:)
      @state = { }
      @user = user
      @pass = pass
      @host = host
      @port = port
      @tcp = tcp
      @socket = connect(host: @host, port: @port, tcp: @tcp, dev: dev)
      TextFlight::CLI.read_response(socket: @socket)

      if dev
        TextFlight::CLI.register(socket: @socket, user: @user, pass: @pass)
      end

      TextFlight::CLI.login(socket: @socket, user: @user, pass: @pass)
      TextFlight::CLI.enable_client_mode(socket: @socket)

      status_report = TextFlight::CLI.status(socket: @socket)
      nav = TextFlight::CLI.nav(socket: @socket)

      @prompt = TFClient::TFPrompt.new(operator: @user,
                                       status_report: status_report)
      @prompt.x = nav.coordinates.x
      @prompt.y = nav.coordinates.y
      read_eval_print
    end

    def connect(host:, port:, tcp:, dev:)
      puts "try to connect to #{host}:#{port} with #{tcp ? "tcp" : "ssl"}"
      if tcp
        socket = TCPSocket.new(host, port)
      else
        ssl_context = OpenSSL::SSL::SSLContext.new
        if dev
          ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        tcp_socket = TCPSocket.new(host, port)
        socket = OpenSSL::SSL::SSLSocket.new(tcp_socket, ssl_context)
        socket.sync_close = true
        socket.connect
      end
      socket
    end

    def read_eval_print
      begin
        loop do
          command = Readline.readline("#{@prompt.to_s}", true)
          if command.strip == ""
            next
          end
          parsed_command = TFClient::CommandParser.new(command: command).parse

          if parsed_command == "exit"
            TextFlight::CLI.write_command(socket: socket, command: parsed_command)
            socket.close
            puts "Goodbye."
            exit(0)
          end

          TextFlight::CLI.write_command(socket: socket, command: parsed_command)

          # set, jump reply with STATUSREPORT
          response = TextFlight::CLI.read_response(socket: @socket)
          instance = TFClient::ResponseParser.new(command: command,
                                                  textflight_command: parsed_command,
                                                  response: response).parse
          if instance.is_a?(TFClient::Models::StatusReport)
            @prompt.mass = instance.hash[:mass].to_i
            @prompt.warp_charge = instance.hash[:warp_charge]
            @prompt.shield_charge = instance.hash[:shield]
          end

          if instance.is_a?(TFClient::Models::Nav)
            @prompt.x = instance.coordinates.x
            @prompt.y = instance.coordinates.y
          end
        end
      rescue IOError => e
        puts e.message
        # e.backtrace
        @socket.close
      end
    end
  end
end

require "dotenv/load" # load from .env
require "tfclient"

env = ARGV.include?("--dev") ? "DEV" : "TF"
tcp = ARGV.include?("--tcp")
host = ENV["#{env}_HOST"] || "localhost"
port = ENV["#{env}_PORT"] || "10000"
user = ARGV[0] || ENV["#{env}_USER"] || "abc"
pass = ENV["#{env}_PASS"] || "1234"

TextFlight::CLI.new(host: host, port: port, tcp: tcp, user: user, pass: pass, dev: env == "DEV")