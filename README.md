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

### Developing

I develop and test on macOS.  The GitHub Actions run rspec tests on Ubuntu,

To run integration tests, the TextFlight server needs to be running.  There
are two options: building the server yourself or using the docker container.

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
$ socat readline tcp:leagueh.xyz:10000
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
