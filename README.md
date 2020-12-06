## TextFlight Client

A command-line client for the TextFlight.

TextFlight is a space-based text adventure MMO.

https://leagueh.xyz/tf/
https://leagueh.xyz/git/textflight/

```
# TextFlight character
jmoody
faction: nibiru
```

One of the first computer games I played was Zork I on an Apple IIc.  The first
program of any significance that I wrote was a text-based adventure in C# based
on my experiences as student worker at the Physical Sciences library at UMass
Amherst.  I played way too much BatMUD in the early nineties and early 2000s.

### Requirements

I develop and test on macOS.  The GitHub Actions run rspec tests on Ubuntu.

* Ruby >= 2.7.0
* Python 3.x

`socat` is essential for debugging - I installed this with brew.

If you want to use openssl, install with `brew openssl` and use
`/usr/local/opt/openssl/bin/openssl` instead of Apple's LibreSSL.

### Developing

To run integration tests and debug, a TextFlight server needs to be running
locally.  There are two options: building the server yourself or using the
docker container.

#### Build It Yourself

```
$ git clone https://leagueh.xyz/git/textflight/.git/
```

The server requires Python 3.x; I use 3.9.0.  I use pyenv to manage Python
versions. Other than that, I don't know anything about Python (my Algorithms
class at Smith in 2001 was in Python...) or how to configure Python on macOS.
There is a little documentation in the textflight/README.md

```
# Run the server like this:
$ cd textflight
$ pip3 install bcrypt
$ src/main.py
...
2020-12-04 23:17:25,110 INFO:Loaded quest 'Base Building'.
2020-12-04 23:17:25,110 INFO:Loaded quest 'Starting Colonies'.

# In another terminal, connect to the server like this:
$ socat readline tcp:leagueh.xyz:10000
```

#### Use Docker

```
$ docker-compose up
...
tcp_1  | 2020-12-05 01:35:37,493 INFO:Loaded quest 'Base Building'.
tcp_1  | 2020-12-05 01:35:37,493 INFO:Loaded quest 'Starting Colonies'.

# In another terminal, connect to the server like this:
$ socat readline tcp:localhost:10000
```

#### OpenSSL

```
1. In the server directory, generate a self-sign cert.

$ cd textflight
$ mkdir -p certs
# change the -subj
$ openssl \
  req -x509 \
  -newkey rsa:4096 \
  -keyout certs/key.pem \
  -out certs/cert.pem \
  -days 365 \
  -nodes \
  -subj "/C=DE/ST=BW/L=Konstanz/O=nibiru/OU=Org/CN=localhost"

2. Install a textflight.conf and update the conf to use SSL
$ cp textflight.conf.example textflight.conf
SSL = true
SSLCert = certs/cert.pem
SSLKey = certs/key.pem

3. Start the server.
$ src/main.py

4. Connect the client.  Without verify=0, the client will refuse
   to connect with an error "unknown ca" (certificate authority).
# Test connection with socat
$ socat readline ssl:localhost:10000,verify=0

# Or with this client
$ bin/client.rb --ssl --dev
```

### Test

```
$ bundle install
$ bundle exec spec/lib
```

Integration tests require standing up the TextFlight server locally (see the
Developing section above).

```
$ bundle install
$ bundle  exec spec/integration
```

### TODO

- [x] setup textflight.conf
- [x] send 'language client'
- [x] if we send commands too fast, the socket buffer fills and the server cannot respond
- [x] we need a way of reading until there is no more output.  a non-blocking read on the socket
- [x] stand up OpenSSL server locally -- broke?
- [x] consolidate special case read_response methods into one method. WOOT!
- [x] ask about WARNING:EOF occurred in violation of protocol (_ssl.c:1122) in IRC
     * possibly send EOT `\004'`
- [x] setup docker
- [x] setup dotenv
- [ ] stand up thor to improve cli
- [ ] add a logger to client
- [ ] control logger with ENV / cli
- [ ] submit changes to upstream server
