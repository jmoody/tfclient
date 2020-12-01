#!/usr/bin/env ruby

require "openssl"
require "thread"
require "socket"
require "readline"
require_relative "lib/tfclient/string_utils"
require "pry"


class Client

  def self.topmatter(socket)
    puts "beginning top matter"
    begin
      loop do
        response = socket.gets
        puts "[0] #{response}"
        if response[/Chat with us on Freenode/]
          break
        end
      end
      puts "end of top matter"
    rescue IOError => e
      puts e.message
      # e.backtrace
      socket.close
    end
    puts "end of function"
  end

  def socket_read_response
    response = nil
    loop do
      response = @socket.gets.dump


      if response
        response.chomp!

      end

      if response[0] == '>'
        response = response[1..-1]
      end


      response.chomp! if response

      response.strip_control_characters!p

      break if response == ""
    end
    response
  end

  def initialize(socket)
    @socket = socket
    Client.topmatter(@socket)
    read_eval_print

    # @request_object = send_request
    # @response_object = listen_response
    #
    # @request_object.join
    # @response_object.join
  end

  def read_eval_print
    begin
      loop do
        puts "read"
        command = Readline.readline("textflight > ", true)
        @socket.puts command

        puts "eval"
        loop do
          response = @socket.gets.dump
          binding.pry

          response = TFClient::StringUtils.remove_control_chars(response)

          if response[0] == '>'
            puts "[trimming]"
            response = response[1..-1]
          end

          response.chomp! if response

          break if response == ""
          puts "[1] #{response}"
        end
      end
    rescue IOError => e
      puts e.message
      # e.backtrace
      @socket.close
    end
  end

#   def send_request
#     begin
#       Thread.new do
#         loop do
#           message = Readline.readline("textflight > ", true)
#           @socket.puts message  if message != ""
#         end
#       end
#     rescue IOError => e
#       puts e.message
#       # e.backtrace
#       @socket.close
#     end
#
#   end
#
  def listen_response
    begin
      Thread.new do
        loop do
          response = @socket.gets
          if response[0] == '>'
            response = response[1..-1]
          end

          response.chomp! if response

          $stdout.puts "#{response}"
          $stdout.flush
        end
      end
    rescue IOError => e
      puts e.message
      # e.backtrace
      @socket.close
    end
  end
end

host = "localhost"
port = 10000
socket  = TCPSocket.new(host, port)
Client.new(socket)
