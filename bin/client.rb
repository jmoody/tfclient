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
              puts "received :wait_readable on try: #{tries} of #{max_tries}; retrying"
              tries = tries + 1
              sleep(0.5)
              next
            else
              puts "received :wait_readable on try: #{tries} of #{max_tries}; breaking"
              # could be we have to exit here
              break
            end
          elsif response == nil
            puts "received 'nil' on try: #{tries} of #{max_tries}; exiting"
            raise("Server returned nil, possibly because of rate limiting")
          end

          puts "received #{response.bytesize} bytes; pushing onto buffer"
          tries = 1
          response.delete_prefix!("> ")
          response.delete_suffix!("> ")
          response = TFClient::StringUtils.remove_terminal_control_chars(string: response)
          response = TFClient::StringUtils.remove_color_control_chars(string: response)
          buffer = buffer + response

          sleep(0.5)
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

      buffer.lines(chomp:true)
    end

    def self.parse_response(response:)
      response.each do |line|
        puts "#{line}"
      end
    end

    def self.register(socket:, user:, pass:)
      puts("=== REGISTER ===")
      puts("user: #{user} pass: #{pass[0..3]}***")
      sleep(0.5)
      self.write_command(socket: socket, command: "register #{user} #{pass}")

      response = self.read_response(socket: socket)
      response.each do |line|
        puts "#{line}"
      end

    end

    def self.login(socket:, user:, pass:)
      puts("=== LOGIN ===")
      puts("user: #{user} pass: #{pass[0..3]}***")
      sleep(0.5)
      self.write_command(socket: socket, command: "login #{user} #{pass}")

      response = self.read_response(socket: socket)
      if response[0] && response[0].chomp == "Incorrect username or password."
        puts "#{response[0].chomp}"
        socket.close
        exit(1)
      end

      response.each do |line|
        puts "#{line}"
      end
    end

    def self.enable_client_mode(socket:)
      sleep(0.5)
      puts("=== ENABLE CLIENT MODE ===")
      self.write_command(socket: socket, command: "language client")
      response = self.read_response(socket: socket)
      response.each do |line|
        puts "#{line}"
      end
    end

    attr_reader :socket, :user, :pass, :host, :port, :ssl, :state, :dev

    def initialize(host:, port:, ssl:, user:, pass:, dev:)
      @state = { }
      @user = user
      @pass = pass
      @host = host
      @port = port
      @ssl = ssl
      @socket = connect(host: @host, port: @port, ssl: @ssl, dev: dev)
      TextFlight::CLI.read_response(socket: @socket)
      TextFlight::CLI.register(socket: @socket, user: @user, pass: @pass)
      TextFlight::CLI.login(socket: @socket, user: @user, pass: @pass)
      TextFlight::CLI.enable_client_mode(socket: @socket)
      read_eval_print
    end

    def connect(host:, port:, ssl:, dev:)
      puts "try to connect to #{host}:#{port} with ssl = #{ssl}"
      if ssl
        ssl_context = OpenSSL::SSL::SSLContext.new
        if dev
          ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        tcp_socket = TCPSocket.new(host, port)
        socket = OpenSSL::SSL::SSLSocket.new(tcp_socket, ssl_context)
        socket.sync_close = true
        socket.connect
      else
        socket = TCPSocket.new(host, port)
      end
      socket
    end

    def read_eval_print
      begin
        loop do
          command = Readline.readline("tf > ", true)
          parsed_command = TFClient::CommandParser.new(command: command).parse

          if parsed_command == "exit"
            TextFlight::CLI.write_command(socket: socket, command: parsed_command)
            socket.close
            puts "Goodbye."
            exit(0)
          end

          TextFlight::CLI.write_command(socket: socket, command: parsed_command)

          response = TextFlight::CLI.read_response(socket: @socket)
          TextFlight::CLI.parse_response(response: response)
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
ssl = ARGV.include?("--ssl")
host = ENV["#{env}_HOST"] || "localhost"
port = ENV["#{env}_PORT"] || "10000"
user = ENV["#{env}_USER"] || "abc"
pass = ENV["#{env}_PASS"] || "1234"

TextFlight::CLI.new(host: host, port: port, ssl: ssl, user: user, pass: pass, dev: env == "DEV")