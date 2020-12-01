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
      lines = []

      timeout = Time.now + 5
      begin
        loop do

          # if socket.wait_readable(1.0) != true
          #   puts "waited for 1 seconds for socket to be readable before breaking"
          #   break
          # end
          #
          response = socket.gets

          # nil means socket has set EOF
          if response.nil?
            raise "server set EOF"
          end

          if response.length != 0
            puts "received response of length: #{response.length}"
            if response[0] == ">"
              puts "received prompt, end of input; breaking '#{response.chomp}'"
              break
            end

            if response[/Chat with us on Freenode!/]
              puts "received freenode message; breaking"
              lines << response.chomp!
              break
            end

            lines << response.chomp!

            if Time.now > timeout
              puts "waited 7 seconds; breaking"
              break
            end
          end
        end
      rescue IOError => e
        puts e.message
        # e.backtrace
        socket.close
      end
      lines
    end

    def self.parse_response(response:)
      response.each do |line|
        puts "#{line}"
      end
    end

    def self.handle_beginning_text(socket:)
      lines = []
      timeout = Time.now + 5
      begin
        loop do
          response = socket.gets
          raise "server sent EOF" if response.nil?
          if response.length != 0
            puts "received line: '#{response.chomp}'"
            lines << response.chomp!
            if response[/Chat with us on Freenode!/]
              puts "received freenode message; breaking"
              lines << response.chomp!
              break
            end
          end

          if Time.now > timeout
            puts "waited 5 seconds; breaking"
            break
          end

          sleep(0.1)
        end
      rescue IOError => e
        puts e.message
        # e.backtrace
        socket.close
      end
      lines.each do |line|
        puts "#{line}"
      end
    end

    def self.login(socket:)
      puts("=== LOGIN ===")
      sleep(1.0)
      socket.puts("login abc 1234")

      lines = []
      timeout = Time.now + 5

      prompt_count = 0
      begin
        loop do
          response = socket.gets
          raise "server sent EOF" if response.nil?

          if response.length != 0
            if response[0] == ">" && prompt_count == 0
              prompt_count = prompt_count + 1
              lines << TFClient::StringUtils.remove_control_chars(response).chomp
              puts "received first prompt, removed ctl chars: '#{lines.last}'"
              sleep(0.1)
              next
            end

            if response[0] == ">"  && prompt_count == 1
              prompt_count = prompt_count + 1
              lines << TFClient::StringUtils.remove_control_chars(response).chomp
              puts "received second prompt; breaking: '#{lines.last}'"
              break
            end

            if response[/Quest/]
              puts "received 'Quest' line - ignoring"
              next
            end

            if response[/'abc' connected to server./]
              puts "received connected message; breaking"
              lines << response.chomp
              break
            end

            #puts "received text (truncated): '#{response.chomp}'"
            lines << response.chomp
          end

          if Time.now > timeout
            puts "waited 5 seconds; breaking"
            break
          end

          puts "elapsed = #{Time.now - timeout}"
          sleep(0.1)
        end
      rescue IOError => e
        puts e.message
        # e.backtrace
        socket.close
      end

      lines.each do |line|
        puts "#{line}"
      end
    end

    def initialize(socket)
      @socket = socket
      TextFlight::CLI.handle_beginning_text(socket: @socket)
      TextFlight::CLI.login(socket: @socket)
      #read_eval_print
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
socket  = TCPSocket.new(host, port)
TextFlight::CLI.new(socket)
