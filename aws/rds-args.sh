#!/bin/bash

log() {
  echo "$@" >&2
}

die() {
  log "$@" >&2
  exit 1
}

syntax() {
  die "Args: <secret-name>"
}

get_args() {
  SECRET=$1
  aws secretsmanager get-secret-value --secret-id "$SECRET" | jq '.SecretString' -r | jq '"-u " + .username + " -p" + .password + " -h " + .host' -r
}

set -e

SECRET=$1
[ -z "$SECRET" ] && syntax

get_args $SECRET

# vim: set sw=2 ts=2 ai nocidnent :
