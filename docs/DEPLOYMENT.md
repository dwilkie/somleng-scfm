# Deployment

## Docker

The following section decribes how to deploy Somleng Simple Call Flow Manager with Docker using and SQLite database.

### Pull the latest Docker image

```
$ sudo docker pull dwilkie/somleng-scfm-avf
```

### Setup Database

#### Create Database (SQLite)

Creates a new database called `somleng_scfm_production` and copies it to the host directory `/etc/somleng-scfm/db`. Modify the command below to change these defaults.

```
$ sudo docker run --rm -v /etc/somleng-scfm/db:/tmp/db -e RAILS_ENV=production -e RAILS_DB_ADAPTER=sqlite3 -e DATABASE_NAME=somleng_scfm_production dwilkie/somleng-scfm-avf /bin/bash -c 'bundle exec rake db:create && bundle exec rake db:migrate && if [ ! -f /tmp/db/somleng_scfm_production.sqlite3 ]; then cp /usr/src/app/db/somleng_scfm_production.sqlite3 /tmp/db; fi'
```

#### Import Contacts

Imports contacts into the production database (using [the example import script](https://github.com/dwilkie/somleng-scfm-avf/blob/master/examples/import_contacts.rb)). Assumes the import file is called `data.csv`, is located `/etc/somleng-scfm/data` and has a header row. Modify the command below to change these defaults.

```
$ sudo docker run -t --rm -v /etc/somleng-scfm/data:/tmp/data:ro -v /etc/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production -e RAILS_DB_ADAPTER=sqlite3 -e DATABASE_NAME=somleng_scfm_production -e HEADER_ROW=1 -e IMPORT_FILE=/tmp/data/data.csv dwilkie/somleng-scfm-avf /bin/bash -c 'bundle exec rails runner /usr/src/app/examples/import_contacts.rb'
```

### Export Cron

Exports cron scripts with sensible defaults to `/etc/somleng-scfm/cron`. Modify the command below to change these defaults or edit them in the exported cron scripts. For additional configuration options see [the install task](https://github.com/dwilkie/somleng-scfm-avf/blob/master/app/tasks/install_task.rb) and the [.env](https://github.com/dwilkie/somleng-scfm-avf/blob/master/.env) file.

```
$ sudo docker run --rm -v /etc/somleng-scfm/cron:/usr/src/app/install/cron -e RAILS_ENV=production -e HOST_INSTALL_DIR=/etc/somleng-scfm dwilkie/somleng-scfm-avf /bin/bash -c 'bundle exec rake task:install:cron'
```

### List available Rake Tasks

Lists all availabe rake tasks

```
$ sudo docker run --rm -e RAILS_ENV=production dwilkie/somleng-scfm-avf /bin/bash -c 'bundle exec rake -T'
```

### Boot the Rails Console

```
$ sudo docker run --rm -it -v /etc/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production dwilkie/somleng-scfm-avf bundle exec rails c
```

### Boot the Database Console

```
$ sudo docker run --rm -it -v /etc/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production dwilkie/somleng-scfm-avf bundle exec rails dbconsole
```
