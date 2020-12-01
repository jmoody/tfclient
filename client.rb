#!/usr/bin/env ruby

require "socket"
require "thread"
require "openssl"
require "readline"

host = "localhost"
port = 10000

client = TCPSocket.new(host, port)
client.autoclose = true
# ssl = OpenSSL::SSL::SSLSocket.new(socket)
# ssl.sync_close = true
#
# ssl.connect

def logout(ssl_client)
  begin
    ssl_client.puts("exit")
    puts "  called exit on server"
	rescue
    puts "  did not call exit on server"
  ensure
		ssl_client.close()
	end
end

def server_response(server)
  begin
    while(response = server.gets())
      return response
    end
  rescue
    $stderr.puts("Error in server loop: #{$!}")
    $stderr.flush()
  end
end

def send_command(ssl, cmd)
  ssl.puts(cmd)
  ssl.flush()
  lines = server_response(ssl)
  process_response(lines)
end

def process_response(lines)
  puts lines
end

#ssl.puts("login ydoomj refuse-taken-overland")
#ssl.flush()
#response = server_response(ssl)
#puts response[-1]
#
#sleep(1)
#
#ssl.puts("scan")
#ssl.flush()
#response = server_response(ssl)
#puts response[-1]

begin
  Thread.new do
    loop do
      response = client.gets.chomp
      puts "#{response}"
      if response[/You are not logged in/]
        break
      end
    end
  end
rescue IOError => e
  puts e.message
  # e.backtrace
  client.close
  exit(1)
end

# while true
#   while command = Readline.readline("textflight > ", true)
#     puts "in input loop"
#     case command
#     when "exit"
#       logout(client)
#       exit(0)
#     when "login"
#       send_command(client, "login ydoomj refuse-taken-overland")
#     else
#       send_command(client, command)
#     end
#   end
# end

trap "SIGINT" do
  puts "trapped SIGINT"
  logout(client)
end

