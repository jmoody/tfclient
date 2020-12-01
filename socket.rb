# #!/usr/bin/env ruby
#
# require "openssl"
# require "thread"
# require "socket"
# require "readline"
# require "tfclient"
# require "pry"
#
# module TextFlight
#   module CLI
#     def self.read_response(socket)
#       response = nil
#       begin
#         loop do
#           response = socket.gets
#
#           if response && response != ""
#             response = TFClient::StringUtils.remove_control_chars(response)
#             if response[0] == '>'
#               response = response[1..-1]
#             end
#             response.chomp! if response
#           end
#
#           break if response == ""
#         end
#       rescue IOError => e
#         puts e.message
#         # e.backtrace
#         socket.close
#       end
#       response
#     end
#
#     def self.parse_response(response)
#       puts "#{response}"
#     end
#
#     def self.handle_beginning_text(socket)
#       response = read_response(socket)
#       puts "#{response}"
#     end
#
#     def initialize(socket)
#       @socket = socket
#       TextFlight::CLI.handle_beginning_text(@socket)
#       read_eval_print
#     end
#
#     def read_eval_print
#       begin
#         loop do
#           puts "read"
#           command = Readline.readline("textflight > ", true)
#           @socket.puts command
#
#           response = self.read_response(@socket)
#           TFClient::StringUtils.parse_response(response)
#         end
#       rescue IOError => e
#         puts e.message
#         # e.backtrace
#         @socket.close
#       end
#     end
#   end
# end
#
# host = "localhost"
# port = 10000
# socket  = TCPSocket.new(host, port)
# TextFlight::CLI.new(socket)
