
RSpec.describe "TextFlight::CLI" do

  class TFTest
    require "command_runner"
    require "openssl"
    require "socket"
    require "readline"

    def server_running?
      hash = CommandRunner.run("docker ps")

      if hash[:status].exitstatus != 0
        TFClient.error("Expected `docker ps` to run, but found:")
        TFClient.error(hash[:out])
        exit(1)
      end
      hash[:out][/src\/main\.py/] ? true : false
    end

    def ensure_server_running
      return if server_running?

      hash = CommandRunner.run("docker-compose up --build --remove-orphans --detach")
      if hash[:status].exitstatus != 0
        TFClient.error("Expected `docker-compose` to run, but found:")
        TFClient.error(hash[:out])
        exit(1)
      end

      timeout = Time.now + 10

      loop do
        sleep(1.0)
        if Time.now > timeout
          TFClient.error("Timed out waiting after 10 seconds for server to start to in container")
          exit(1)
        end

        break if server_running?
      end
    end
  end

  before(:all) do
    TFTest.new.ensure_server_running
    @socket = TFClient::Setup.connect(host: "localhost",
                                      port: 10000,
                                      tcp: false,
                                      dev: true)
    user = "abc"
    pass = "1234"
    TFClient::IO.read_response(socket: @socket)
    TFClient::Setup.register(socket: @socket, user: user, pass: pass)
    TFClient::Setup.login(socket: @socket, user: user, pass: pass)
    TFClient::Setup.enable_client_mode(socket: @socket)
  end

  after(:all) do
    if @socket
      @socket.close
    end
  end

  it "can handle the response from the 'nav' command" do
    nav = nil
    out = Kernel.capture_stdout do
      nav = TFClient::Setup.nav(socket: @socket)
    end

    puts out

    expect(out[/Brightness/]).to be_truthy
    expect(out[/Planets/]).to be_truthy
    expect(out[/Links/]).to be_truthy
    expect(out[/Structures/]).to be_truthy

    expect(nav.is_a?(TFClient::Models::Server::Nav)).to be == true
  end

  it "can handle the response from the 'scan' command" do
    scan = nil
    out = Kernel.capture_stdout do
      sleep(0.5)
      TFClient::IO.write_command(socket: @socket, command: "scan")
      sleep(0.5)
      response = TFClient::IO.read_response(socket: @socket)
      scan = TFClient::ResponseParser.new(command: "scan",
                                          textflight_command: "scan",
                                          response: response).parse
    end
    puts out

    expect(out[/Outfits/]).to be_truthy
    expect(out[/Weight/]).to be_truthy

    expect(scan.is_a?(TFClient::Models::Server::Scan)).to be == true
  end

  it "can handle the response from the 'status' command" do
    status = nil
    out = Kernel.capture_stdout do
      status = TFClient::Setup.status(socket: @socket)
    end

    puts out

    expect(out[/General/]).to be_truthy
    expect(out[/Stability/]).to be_truthy
    expect(out[/Shields/]).to be_truthy
    expect(out[/Warp engines/]).to be_truthy

    expect(status.is_a?(TFClient::Models::Server::Status)).to be == true
  end

  it "can handle the response from the 'craft' command" do
    craft = nil
    out = Kernel.capture_stdout do
      sleep(0.5)
      TFClient::IO.write_command(socket: @socket, command: "craft")
      sleep(0.5)
      response = TFClient::IO.read_response(socket: @socket)
      craft = TFClient::ResponseParser.new(command: "craft",
                                          textflight_command: "craft",
                                          response: response).parse
    end
    puts out

    expect(craft).to be == nil
  end
end