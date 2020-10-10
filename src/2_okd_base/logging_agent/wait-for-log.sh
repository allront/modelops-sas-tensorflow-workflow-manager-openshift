#!/bin/sh
# Wrapper script to control startup of logger
# https://docs.docker.com/compose/startup-order/

set -e

file="$1"
shift 1
cmd="$@"

# wait for the log file
until test -e $file
do
  >&2 echo "Waiting for log file at $file..."
  sleep 1
done

# run the command
>&2 echo "Found log file at $file!"
exec $cmd