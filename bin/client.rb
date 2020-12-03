#!/usr/bin/env ruby

require "openssl"
require "thread"
require "socket"
require "readline"
require "tfclient"
require "pry"

module TextFlight
  class CLI

    def self.read_response(socket:)
      timeout = 5.0
      ready = IO.select([socket], nil, nil, timeout)

      if !ready
        message = "Timed out waiting for socket to response after #{timeout} seconds"
        socket.close if socket.present?
        raise message
      end

      buffer = ""
      max_tries = 5
      tries = 1
      begin
        loop do
          response = socket.read_nonblock(4096, exception: false)

          if response == :wait_readable
            if tries < max_tries
              puts "received :wait_readable on try: #{tries} of #{max_tries}; retrying"
              tries = tries + 1
              next
            else
              puts "received :wait_readable on try: #{tries} of #{max_tries}; breaking"
              break
            end
          end

          puts "received #{response.bytesize} bytes; pushing onto buffer"
          response.delete_prefix!("> ")
          response.delete_suffix!("> ")
          response = TFClient::StringUtils.remove_terminal_control_chars(string: response)
          response = TFClient::StringUtils.remove_color_control_chars(string: response)
          buffer = buffer + response

          sleep(0.1)
        end
      rescue StandardError, IOError => e
        message = <<~EOM
          Caught error while reading from socket:

          #{e.message}

          after reading #{buffer.bytesize} from socket:

          #{buffer}
        EOM
        socket.close
        raise(e.class, message)
      end

      return buffer.lines(chomp:true).map do |line|
        line.strip
      end.reject do |line|
        line.length == 0
      end
    end

    def self.parse_response(response:)
      response.each do |line|
        puts "#{line}"
      end
    end

    def self.login(socket:)
      puts("=== LOGIN ===")
      socket.puts("login abc 1234")
      response = self.read_response(socket: socket)
      response.each do |line|
        puts "#{line}"
      end
    end

    def self.enable_client_mode(socket:)
      puts("=== ENABLE CLIENT MODE ===")
      socket.puts("language client")
      response = self.read_response(socket: socket)
      response.each do |line|
        puts "#{line}"
      end
    end

    def initialize(socket)
      @socket = socket
      TextFlight::CLI.read_response(socket: @socket)
      sleep(1.0)
      TextFlight::CLI.login(socket: @socket)
      sleep(1.0)
      TextFlight::CLI.enable_client_mode(socket: @socket)
      read_eval_print
    end

    def read_eval_print
      begin
        loop do
          command = Readline.readline("textflight > ", true)
          @socket.puts command

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

host = "localhost"
port = 10000
tcp = TCPSocket.new(host, port)
socket = OpenSSL::SSL::SSLSocket.new(tcp)
socket.sync_close = true
socket.connect
TextFlight::CLI.new(socket)
