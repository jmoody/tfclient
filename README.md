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

To run integration tests, the TextFlight server needs to be running.

```
$ git clone https://leagueh.xyz/git/textflight/.git/ 
```

The server requires Python 3.x; I use 3.9.0.  I use pyenv to manage Python
versions. Other than that, I don't know anything about Python (my Algorithms
class at Smith in 2001 was in Python...) or how to configure Python on macOS.

```
# Run the server like this:
$ cd testflight
$ src/main.py
```

I would like to make a Docker container to host the server...

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

