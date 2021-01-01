#!/usr/bin/env ruby

module TextFlight
  require "openssl"
  require "socket"
  require "readline"
  require "pry"

  class CLI

    attr_reader :socket, :user, :pass, :host, :port, :tcp, :state, :dev
    attr_reader :local_db

    def initialize(host:, port:, tcp:, user:, pass:, dev:)
      db_path = TFClient::DotDir.local_database_file(dev: dev)
      @local_db = TFClient::Models::Local::Database.new(path: db_path)
      @state = { }
      @user = user
      @pass = pass
      @host = host
      @port = port
      @tcp = tcp
      @socket = TFClient::Setup.connect(host: @host,
                                        port: @port,
                                        tcp: @tcp,
                                        dev: dev)
      TFClient::IO.read_response(socket: @socket)

      if dev
        TFClient::Setup.register(socket: @socket, user: @user, pass: @pass)
      end

      TFClient::Setup.login(socket: @socket, user: @user, pass: @pass)
      TFClient::Setup.enable_client_mode(socket: @socket)

      update_prompt!
      read_eval_print
    end

    # def connect(host:, port:, tcp:, dev:)
    #   puts "try to connect to #{host}:#{port} with #{tcp ? "tcp" : "ssl"}"
    #   if tcp
    #     socket = TCPSocket.new(host, port)
    #   else
    #     ssl_context = OpenSSL::SSL::SSLContext.new
    #     if dev
    #       ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
    #     end
    #     tcp_socket = TCPSocket.new(host, port)
    #     socket = OpenSSL::SSL::SSLSocket.new(tcp_socket, ssl_context)
    #     socket.sync_close = true
    #     socket.connect
    #   end
    #   socket
    # end

    def update_prompt!
      TFClient::IO.write_command(socket: @socket, command: "status")
      response = TFClient::IO.read_response(socket: @socket)
      status = TFClient::ResponseParser.new(command: "status-for-prompt",
                                            textflight_command: "status",
                                            response: response).parse

      @prompt = TFClient::TFPrompt.new(operator:@user,
                                       status_report: status.status_report)

      system_id = status.system_id

      # We did not move, so don't bother with a #nav request
      if @prompt.x && @prompt.system_id && @prompt.system_id == system_id
        return
      end

      @prompt.system_id = system_id

      system = @local_db.system_for_id(system_id: system_id)

      if system.count == 0
        TFClient::IO.write_command(socket: socket, command: "nav")
        response = TFClient::IO.read_response(socket: @socket)
        nav = TFClient::ResponseParser.new(command: "nav-for-prompt",
                                           textflight_command: "nav",
                                           response: response).parse
        @local_db.create_system(system_id: system_id, nav: nav)
        @prompt.x = nav.coordinates.x
        @prompt.y = nav.coordinates.y
      else
        @prompt.x = system.first[:x]
        @prompt.y = system.first[:y]
      end
    end

    def read_eval_print
      begin
        loop do
          command = Readline.readline("#{@prompt.to_s}", true)
          if command.strip == ""
            update_prompt!
            next
          end


          parsed_command = TFClient::CommandParser.new(command: command).parse

          if parsed_command == "exit"
            TFClient::IO.write_command(socket: socket, command: parsed_command)
            socket.close
            puts "Goodbye."
            exit(0)
          end

          TFClient::IO.write_command(socket: socket, command: parsed_command)

          # rdock, dock, set, jump reply with STATUSREPORT
          response = TFClient::IO.read_response(socket: @socket)
          TFClient::ResponseParser.new(command: command,
                                       textflight_command: parsed_command,
                                       response: response).parse

          update_prompt!
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
require "textflight-client"

env = ARGV.include?("--dev") ? "DEV" : "TF"
tcp = ARGV.include?("--tcp")
host = ENV["#{env}_HOST"] || "localhost"
port = ENV["#{env}_PORT"] || "10000"

if ARGV[0][/--/]
  user = ENV["#{env}_USER"] || "abc"
else
  user = ARGV[0]
end
pass = ENV["#{env}_PASS"] || "1234"

TextFlight::CLI.new(host: host,
                    port: port,
                    tcp: tcp,
                    user: user,
                    pass: pass,
                    dev: env == "DEV")