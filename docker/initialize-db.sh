#!/bin/bash

PROJECT=$1

die() {
    echo $*
    exit 1
}

set -e

[[ -z "${PROJECT}" ]] && die "You must pass a project name in parameter. For example: $0 fleet"

docker-compose -p ${PROJECT} exec couchbaseserver couchbase-cli cluster-init --cluster-username=admin --cluster-password=123456 --cluster-ramsize=256
docker-compose -p ${PROJECT} exec couchbaseserver couchbase-cli bucket-create --bucket fleet-prod --bucket-type couchbase -c localhost --bucket-ramsize 256 -u admin -p 123456
docker-compose -p ${PROJECT} exec couchbaseserver couchbase-cli user-manage --set -c localhost -u admin -p 123456 --rbac-username fleet-prod --rbac-password 123456 --roles bucket_admin[fleet-prod] --auth-domain local
