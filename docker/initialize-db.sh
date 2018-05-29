#!/bin/bash

PROJECT=$1

die() {
    echo $*
    exit 1
}

set -e

[[ -z "${PROJECT}" ]] && die "You must pass a project name in parameter. For example: $0 fleet"

docker-compose -p ${PROJECT} exec couchbase couchbase-cli cluster-init --cluster couchbase.${HOSTNAME} --services data,index,query --cluster-username=admin --cluster-password=123456 --cluster-ramsize=256
docker-compose -p ${PROJECT} exec couchbase couchbase-cli bucket-create --bucket fleet-prod --bucket-type couchbase -c couchbase.${HOSTNAME} --bucket-ramsize 256 -u admin -p 123456
docker-compose -p ${PROJECT} exec couchbase couchbase-cli user-manage --set -c couchbase.${HOSTNAME} -u admin -p 123456 --rbac-username fleet-prod --rbac-password 123456 --roles bucket_admin[fleet-prod] --auth-domain local

for OTHER_HOSTNAME in ""; do
  docker-compose -p ${PROJECT} exec couchbase couchbase-cli server-add --cluster couchbase.${HOSTNAME} --username=admin --password=123456 --server-add couchbase.${OTHER_HOSTNAME} --server-add-username=admin --server-add-password=123456 --services=data,index,query
  docker-compose -p ${PROJECT} exec couchbase couchbase-cli rebalance --cluster couchbase.${HOSTNAME} --username=admin --password=123456
done
