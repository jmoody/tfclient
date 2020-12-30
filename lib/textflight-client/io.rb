
module TFClient
  module IO
    def self.write_command(socket:, command:)
      timeout = 5.0
      ready = ::IO.select(nil, [socket], nil, timeout)

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
      ready = ::IO.select([socket], nil, nil, timeout)

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
    end
  end
end