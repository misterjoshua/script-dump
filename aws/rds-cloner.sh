#!/bin/bash

log() {
  echo "$@" >&2
}

die(){
  log "$@" >&2
  exit 1
}

syntax() {
  die "Args: <from-secret-name> <from-dbname> <to-secret-name> <to-dbname>"
}

get_args() {
  SECRET=$1
  aws secretsmanager get-secret-value --secret-id "$SECRET" | jq '.SecretString'                                                                                                               -r | jq '"-u " + .username + " -p" + .password + " -h " + .host' -r
}

set -e

FROM_SECRET=$1
FROM_DB=$2
TO_SECRET=$3
TO_DB=$4

[ -z "$FROM_SECRET" ] && syntax
[ -z "$FROM_DB" ] && syntax
[ -z "$TO_SECRET" ] && syntax
[ -z "$TO_DB" ] && syntax

FROM_ARGS=$(get_args $FROM_SECRET)
TO_ARGS=$(get_args $TO_SECRET)

log "Dumping $FROM_SECRET $FROM_DB"
mysqldump $FROM_ARGS --opt $FROM_DB >db.sql

log "Dropping and recreating $TO_SECRET $TO_DB"
echo "DROP DATABASE IF EXISTS $TO_DB; CREATE DATABASE $TO_DB;" | mysql $TO_ARGS

log "Importing to $TO_SECRET $TO_DB"
mysql $TO_ARGS $TO_DB <db.sql

# vim: set sw=2 ts=2 ai nocindent :
