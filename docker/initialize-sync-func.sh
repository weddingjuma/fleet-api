#!/bin/bash

PROJECT=$1

die() {
    echo $*
    exit 1
}

set -e

cd ../SyncFunction
npm run production
cd -
