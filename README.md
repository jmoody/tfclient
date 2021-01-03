## TextFlight Client

A command-line client for TextFlight.

TextFlight is a space-based text adventure MMO.

* https://leagueh.xyz/tf/
* https://leagueh.xyz/git/textflight/

```
# TextFlight character
jmoody
faction: nibiru
```

One of the first computer games I played was Zork on an Apple IIc.  The first
program of any significance that I wrote was a text-based adventure in C# based
on my experiences as student worker at the Physical Sciences library at UMass
Amherst.  I played way too much BatMUD in the early nineties and early 2000s.

### Requirements

I develop and test on macOS.  The GitHub Actions run rspec tests on Ubuntu.

I install dependencies with Homebrew.

* Ruby >= 2.7.0
* sqlite3
* readline
* socat (essential for debugging)

### Installing

Installing with `gem install` will work, but the command-line tool will be a
little awkward to use (see the TODO at the end - use thor to improve CLI).

```
$ git clone https://github.com/jmoody/tfclient.git
$ cd tfclient
$ gem update --system
$ gem install bundler
$ bundle install
```

### Logging In

See also the .env.example.

```
# If you haven't created an account or you want to make a new account.
$ bundle exec bin/client.rb

# When you have an account.
$ bundle exec bin/client.rb <username>
```

### Commands

You will need to refer to this manual often:

https://leagueh.xyz/tf/textflight-manual.html

Use the in-game `help` for a comprehensive list.

To bypass this client's parser, prefix the command with a space.  If something
is not working in this client, using a leading-space will allow you to
workaround the problem or limitation.

```
# handled by this client
> scan

# handled by the native client
>  scan
```

The most important difference between the native client and this client is the
navigation system.  This client models the galaxy (?) using a Cartesian
coordinate system.  The coordinate system is navigated using cardinal
directions.  This is basically the same as native client except in two ways.

1. The x and y are flipped - travelling north increments the position on the
   y axis and travelling south decrements the position on the y axis.
2. Navigation is done using n,ne,e,se,s,sw,w,nw commands.

I designed the navigation system this way because this is how most text-based
games and MUDs work.

There is beta support for plotting courses.  You can plot a course to any system
you have visit or any system that is adjacent to system you have visited.

```
> plot course to {<system> | <x> <y>}

# Plot a course to the 'sol' system.  The system name is set using the
# `faction_name` native command while in the system (and flying, not in your
# base)
> plot course to sol

# Plot a course to a system at coordinate
> plot course to 5 -10
```

### Prompt

The prompt is a work in progress.

- [ ] The 'Shields' part is broken.
- [ ] The operator will be the original operator, not the operator of the
      scanned structure.  Could be a feature?
- [ ] Prompt could include Energy and Cooling status

```
   Shields  Mass    Warp Charge   x,y   operator
>  S: 17%   Ms: 347 Wrp: 0%     (10,20) stern   >
```

### Developing

To run integration tests and debug, a TextFlight server needs to be running
locally.  There are two options: building the server yourself or using the
docker container.  Find the instructions for building the server yourself at the
bottom of this document.

#### Docker

The client has a Docker container that starts the server with SSL enabled.

```
$ bundle exec rake server
docker-compose up --build --remove-orphans
...
ssl_1  | 2020-12-09 06:48:58,318 INFO:Loaded quest 'Refueling'.
ssl_1  | 2020-12-09 06:48:58,318 INFO:Loaded quest 'Base Building'.
ssl_1  | 2020-12-09 06:48:58,319 INFO:Loaded quest 'Starting Colonies'.
```

The certificate is self-signed, so the client should not try to verify the
Certificate Authority.

```
# Connect to the native client: socat
$ socat readline ssl:localhost:10000,verify=0

^ also a rake task: bundle exec rake socat

# Connect with bin/client.rb
# --dev flag turns off certificate validation.
$ bundle exec bin/client.rb --dev
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

- [ ] navigation should automatically eject
- [ ] jumping should show the 'nav'
- [ ] add calculator
- [ ] searching through materials
- [ ] improve the load command (mv all <index> to <structure>)
- [ ] improve 'set' command
  - engines {off | on}
  - mining {off | on}
  - prepare to launch
  - prepare to land
- [ ] improve the prompt
- [ ] handle the craft response
- [ ] improve craft command (craft all [recipe])
- [ ] use thor to improve cli
- [ ] combat...
- [ ] wait for warp drive to charge, then jump
- [ ] automatically follow plan

### Server

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

#### OpenSSL

If you want to use openssl, install with `brew openssl` and use
`/usr/local/opt/openssl/bin/openssl` instead of Apple's LibreSSL.


```
1. In the server directory, generate a self-sign cert.

$ cd textflight
$ mkdir -p certs
# change the -subj
$ /usr/local/opt/openssl/bin/openssl \
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
$ bin/client.rb --dev
```

