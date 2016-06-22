#!/bin/bash

start_xvfb() {
  export DISPLAY=':99.0'
  Xvfb :99 -ac -screen 0 1024x768x8 &
}

main() {
  start_xvfb
}

main
exec "$@"
