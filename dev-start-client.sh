#!/bin/bash

# Start & link "client"

docker run -it -v `pwd`:/code --link server:server erl
