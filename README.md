Mapotempo Fleet
===============
API server for Mapotempo Route

## Installation

1. [Project dependencies](#project-dependencies)
2. [Install Bundler Gem](#install-bundler-gem)
3. [Requirements for all systems](#requirements-for-all-systems)
4. [Install project](#install-project)
5. [Configuration for docker](#configuration)
7. [Initialization](#initialization)
7. [Update Sync Function](#update-sync-function)
8. [Running](#running)

### Project dependencies

Install Ruby (>= 2.3 is needed) and other dependencies from system package.

First, install Ruby :

    sudo apt-get install ruby2.3 ruby2.3-dev

You need some others libs :

    sudo apt-get build-essential libz-dev libicu-dev libevent-dev
    
Next, install docker to run Couchbase :

    sudo apt-get docker docker-compose

__It's important to have all of this installed packages before installing following gems.__

### Install Bundler Gem

Bundler provides a consistent environment for Ruby projects by tracking and installing the exact gems and versions that are needed.
For more information see [Bundler website](http://bundler.io).

To install Bundler Ruby Gem:

    export GEM_HOME=~/.gem/ruby/2.3
    gem install bundler

The GEM_HOME variable is the place who are stored Ruby gems.

## Requirements for all systems

Now add gem bin directory to path with :

    export PATH=$PATH:~/.gem/ruby/2.3/bin

Add environment variables into the end of your .bashrc file :

    nano ~/.bashrc

Add following code :

    # RUBY GEM CONFIG
    export GEM_HOME=~/.gem/ruby/2.3
    export PATH=$PATH:~/.gem/ruby/2.3/bin

Save changes and Quit

Run this command to activate your modifications :

    source ~/.bashrc

### Install project

For the following installation, your current working directory needs to be the mapotempo-fleet root directory.

Clone the project :

    git clone git@gitlab.com:mapotempo/mapotempo-fleet.git

Go to project directory :

    cd mapotempo-fleet

Then install gem project dependencies with :

    bundle install

Note: In case the default Python in the system is Python 3, you must setup a virtualenv with Python 2 to be able to compile native gem libuv. So before running `bundle install`:

    virtualenv -p python2.7 venv2.7
    source venv2.7/bin/activate

## Configuration for docker

### Initialization

First, initialize docker environment before building it: 

    cd docker
    ./initialize-sync-func.sh

The build the docker image:

    sudo docker-compose build

Run the docker:

    sudo docker-compose up

Initialize Couchbase:

    ./initialize-db.sh

It creates a cluster, a bucket and an admin user.

Restart the docker.

### Update Sync Function

To update the sync function (in ./SyncFunction/SyncFunction.js):

    cd ./SyncFunction
    npm run production
    
Restart SyncGateway in the docker.

### Running

Run the docker containing couchbase (8091), sync-gateway (4984 and 4985) and fleet-api (8084): 

    sudo docker-compose up
