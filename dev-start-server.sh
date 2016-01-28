#!/bin/bash

# Start & link "server"

docker run -it -v `pwd`:/code --name 'server' erl
