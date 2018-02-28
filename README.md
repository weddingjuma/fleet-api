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
9. [Migrations](#migrations)
8. [Swagger](#swagger)

### Project dependencies

Install Ruby (>= 2.3 is needed) and other dependencies from system package.

First, install Ruby:

    sudo apt-get install ruby2.3 ruby2.3-dev

You need some others libs:

    sudo apt-get install build-essential libz-dev libicu-dev libevent-dev

Next, install docker to run Couchbase:

    sudo apt-get install docker docker-compose

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

Save changes and quit

Run this command to activate your modifications :

    source ~/.bashrc

### Install project

For the following installation, your current working directory needs to be the mapotempo-fleet root directory.

Clone the project:

    git clone git@gitlab.com:mapotempo/mapotempo-fleet.git

Go to project directory:

    cd mapotempo-fleet

Then install gem project dependencies with:

    bundle install

Note: In case the default Python in the system is Python 3, you must setup a virtualenv with Python 2 to be able to compile native gem libuv. So before running `bundle install`:

    virtualenv -p python2.7 venv2.7
    source venv2.7/bin/activate

You need to install nodeJS for Sync Function:

    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
    curl -sL https://deb.nodesource.com/setup_8.x | bash -
    apt install nodejs

Then install required packages:

    cd ./SynFunction
    npm i

## Configuration for docker

### Initialization

Build the docker image:

    sudo docker-compose build

Update sync function through docker:

    sudo docker-compose -p fleet run --rm wrapper ./initialize-sync-func.sh

Run the docker:

    sudo docker-compose -p fleet up -d

Initialize Couchbase:

    ./initialize-db.sh fleet

It creates a cluster, a bucket and an admin user.

Restart the docker.

### Update Sync Function

Only needed, if sync function has changed.

To update the sync function (in ./SyncFunction/SyncFunction.js) for docker (docker/sync-gateway-config.json):

    cd docker
    ./initialize-sync-func.sh

Restart SyncGateway in the docker.

### Before running

Before running rails server always execute the following migration (ensure consistency of couchbase views):

    rails mapotempo_fleet:ensure_couchbase_views

### Running

Run the docker containing couchbase (8091), sync-gateway (4984 and 4985) and fleet-api (8084):

    sudo docker-compose -p fleet up

### Populate Couchbase database

In order to create initial required data, a populate script is available through:

    bundle exec rails mapotempo_fleet:populate

It performs 3 main things:

- Create Couchbase views to query data in models

- Create an admin account (which _api_key_ is required to create companies)

- Create a default company (_default_) with the default workflow

### Company workflow

In order to proceed nominally, each company needs a workflow. A default workflow is automatically associated to a company when creating it through the API call.

Each workflow is composed of:

- A set of MissionStatusAction, linked to a previous and a next MissionStatusType.

- Only the previous and next MissionStatusType, defined in MissionStatusAction, are accessible from the current MissionStatusType.

- MissionStatusType defined the name of the current status, its color and a svg path.

Finally, each company have an initial status to start with.

The default workflow is defined in _lib/workflow/default_workflow.rb_.

### Create dummies data

In order to test Couchbase, the gem FactoryBot can create dummies data for all models. Theses commands must be run in a console.

All fields which are not specified are automatically populated with fake data, except for relationships. The fake data are defined in _spec/factories/*_ repertory.

Create one data, for a company for instance:

    FactoryBot.create(:company, name: 'default')

Or for a user:

    FactoryBot.create(:company, company: Company.first, name: 'default')

It's also possible to create a set of data in one command, 10 for instance:

    FactoryBot.create_list(:company, 10)

Sometime a field must be uniq, like name, to avoid a conflict, use the fake data and don't specified the field.

## Migrations

To update Couchbase data, migration scripts must be written and executed after deployment of a new version if needed. Executed migrations are stored in SchemaMigration documents. Migrations isn't executed if already present in database (see SchemaMigration document).

To apply all unexecuted migrations, run the command:
 `rails mapotempo_fleet:migrate`

To list all migrations available (prefixed by migration_), run the command:

    rails -T

All scripts are under the directory:

    lib/tasks/migrations

New migration can be add with the following template :
```
namespace :mapotempo_fleet do

  desc 'Descrive the migration'
  task :migration_201802211720_new_migration_name, [] => :environment do |_task, _args|

    # Verify migration execution
    migration_name = _task.name.split(':').last.freeze
    if SchemaMigration.find_by(migration_name)
       p 'migration aborted, reason : already executed'
       next
    end

    # Do migration here

    # Save migration execution
    SchemaMigration.create(migration: migration_name, date: DateTime.now.to_s)
  end
end
```
The name format should be migration_[YEAR MONTH DAY HOUR MINUTE]_name

## Swagger

Generate the Swagger JSON file, before running in production:

    rails rswag:specs:swaggerize
