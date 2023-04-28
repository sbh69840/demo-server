# Demo server

Light weight application with two package `with-euler` (using euler-hs backend) and `without-euler` (vanilla).

## Why?

Compare performance of a server with free monad based euler-hs vs a plain server using servant with IO monad.

## Usage[^1]
[^1]: ghc-8.8.4 will not work on darwin (MacOS) due to lack of support, in which case you can use ghc-8.10.7 which is similar in performance.

### Build and Run
To run `with-euler` executable that is compiled using ghc-8.8.4
```
nix build .#ghc884-with-euler
./result/bin/with-euler
```
With ghc-8.10.7:
```
nix build .#ghc8107-with-euler
./result/bin/with-euler
```
With ghc-9.2.4:
```
nix build .#ghc8107-with-euler
./result/bin/with-euler
```

To build `without-euler` executable, change `with-euler` in above commands to `without-euler`. 

To build `server.cpp` run 
```
nix develop .#cpp
g++ -o server server.cpp -lhirdeis -lredis++
```
### API call
#### with-euler
To allocate a huge hash map and evaluate it without logging entire hash map, run:
`curl "http://localhost:8080/get_foo"`
To allocate and log, run:
`curl "http://localhost:8080/get_foo?log=1"`
#### without-euler
port in the above curl changes to 8081
