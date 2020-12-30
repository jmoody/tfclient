
module TFClient
  module Setup

    def self.connect(host:, port:, tcp:, dev:)
      TFClient.info("try to connect to #{host}:#{port} with #{tcp ? "tcp" : "ssl"}")
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

    def self.register(socket:, user:, pass:)
      TFClient.debug("=== REGISTER ===")
      TFClient.info("registering user: #{user} pass: #{pass[0..3]}***")
      sleep(0.5)
      TFClient::IO.write_command(socket: socket,
                                 command: "register #{user} #{pass}")

      response = TFClient::IO.read_response(socket: socket)
      puts response
    end

    def self.login(socket:, user:, pass:)
      TFClient.debug("=== LOGIN ===")
      TFClient.info("logging in user: #{user} pass: #{pass[0..3]}***")
      sleep(0.5)
      TFClient::IO.write_command(socket: socket,
                                 command: "login #{user} #{pass}")

      response = TFClient::IO.read_response(socket: socket)
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
      TFClient::IO.write_command(socket: socket, command: "language client")
      response = TFClient::IO.read_response(socket: socket)
      puts response
    end

    def self.status(socket:)
      sleep(0.5)
      TFClient::IO.write_command(socket: socket, command: "status")
      sleep(0.5)
      response = TFClient::IO.read_response(socket: socket)
      TFClient::ResponseParser.new(command: "status",
                                   textflight_command: "status",
                                   response: response).parse
    end

    def self.nav(socket:)
      sleep(0.5)
      TFClient::IO.write_command(socket: socket, command: "nav")
      sleep(0.5)
      response = TFClient::IO.read_response(socket: socket)
      TFClient::ResponseParser.new(command: "nav",
                                   textflight_command: "nav",
                                   response: response).parse
    end
  end
end