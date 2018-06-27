# edb cookbook

Installs and configures EDB Postgres Advanced Server (EPAS) as a client or a server.

This cookbook assumes that it is placed in a folder named `edb`

## Requirements

### Platforms

- Red Hat/CentOS 6+
- Fedora

## EPAS version

We follow the currently supported versions listed on <https://www.postgresql.org/support/versioning/>

The earliest supported version is currently:

- 9.6

### Chef

- Chef 13.8+

### Cookbook Dependencies

- `openssl`
- `build-essential`

## Resources

### edb_client_install

This resource installs EPAS client packages.  Note: if the EDB Yum repository is to be installed with `setup_repo`, `edb_username` and `edb_password` must be provided

#### Actions

- `install` - (default) Install client packages

#### Properties

Name                | Types             | Description                                                   | Default                                   | Required?
------------------- | ----------------- | ------------------------------------------------------------- | ----------------------------------------- | ---------
`version`           | String            | Version of EPAS to install                                    | '9.6'                                     | no
`setup_repo`        | Boolean           | Define if you want to add the EPAS repo                       | true                                      | no
`hba_file`          | String            |                                                               | `#{conf_dir}/main/pg_hba.conf`            | no
`ident_file`        | String            |                                                               | `#{conf_dir}/main/pg_ident.conf`          | no
`external_pid_file` | String            |                                                               | `/var/run/edb/#{version}-main.pid`        | no
`password`          | String, nil       | Pass in a password, or have the cookbook generate one for you | 'generate'                                | no
`port`              | [String, Integer] | Database listen port                                          | 5444                                      | no
`initdb_locale`     | String            | Locale to initialize the database with                        | 'UTF-8'                                   | no
`edb_username`      | String            | EDB Yum repository username                                   | ''                                        | no
`edb_password`      | String            | EDB Yum repository password                                   | ''                                        | no

#### Examples

To install '9.6' version:

```
edb_client_install 'My EPAS Client install' do
  version '9.6'
end
```

### edb_server_install

This resource installs EPAS client and server packages.  Note: if the EDB Yum repository is to be installed with `setup_repo`, `edb_username` and `edb_password` must be provided

#### Actions

- `install` - (default) Install client and server packages
- `create` - Initialize the database

#### Properties

Name                | Types           | Description                                   | Default                                            | Required?
------------------- | --------------- | --------------------------------------------- | -------------------------------------------------- | ---------
`version`           | String          | Version of EPAS to install                    | '9.6'                                              | no
`setup_repo`        | Boolean         | Define if you want to add the EPAS repo       | true                                               | no
`hba_file`          | String          | Path of pg_hba.conf file                      | `<default_os_path>/pg_hba.conf'`                   | no
`ident_file`        | String          | Path of pg_ident.conf file                    | `<default_os_path>/pg_ident.conf`                  | no
`external_pid_file` | String          | Path of PID file                              | `/var/run/edb/<version>-main.pid</version>`        | no
`password`          | String, nil     | Set enterprisedb user password                | 'generate'                                         | no
`port`              | String, Integer | Set listen port of EPAS service               | 5444                                               | no
`edb_username`      | String          | EDB Yum repository username                   | ''                                                 | no
`edb_password`      | String          | EDB Yum repository password                   | ''                                                 | no

#### Examples

To install EPAS server, set you own enterprisedb password and set another service port.

```
edb_server_install 'My EPAS Server install' do
  action :install
end

edb_server_install 'Setup my EPAS 9.6 server' do
  password 'MyP4ssw0d'
  port 5433
  action :create
end
```

### edb_server_conf

This resource manages postgresql.conf configuration file.

#### Actions

- `modify` - (default) Manager EPAS configuration file (postgresql.conf)

#### Properties

Name                   | Types  | Description                             | Default                                             | Required?
---------------------- | ------ | --------------------------------------- | --------------------------------------------------- | ---------
`version`              | String | Version of EPAS to install              | '9.6'                                               | no
`data_directory`       | String | Path of EPAS data directory             | `<default_os_data_path>`                            | no
`hba_file`             | String | Path of pg_hba.conf file                | `<default_os_conf_path>/pg_hba.conf`                | no
`ident_file`           | String | Path of pg_ident.conf file              | `<default_os_conf_path>/pg_ident.conf`              | no
`external_pid_file`    | String | Path of PID file                        | `/var/run/edb/<edb_version>-main.pid`               | no
`stats_temp_directory` | String | Path of stats file                      | `/var/run/edb/version>-main.pg_stat_tmp`            | no
`additional_config`    | Hash   | Extra configuration for the config file | {}                                                  | no

#### Examples

To setup your EPAS configuration with a specific data directory. If you have installed a specific version of EPAS (different from 9.6), you must specify version in this resource too.

```
edb_server_conf 'My EPAS Config' do
  version '9.6'
  data_directory '/data/9.6/main'
  notification :reload
end
```

### edb_extension

This resource manages EPAS extensions for a given database.

#### Actions

- `create` - (default) Creates an extension in a given database
- `drop` - Drops an extension from the database

#### Properties

Name          | Types  | Description                                                                      | Default          | Required?
------------- | ------ | -------------------------------------------------------------------------------- | ---------------- | ---------
`database`    | String | Name of the database to install the extension into                               |                  | yes
`extension`   | String | Name of the extension to install the database                                    | Name of resource | yes
`old_version` | String | Older module name for new extension replacement. Appends FROM to extension query |                  | no

#### Examples

To install the `adminpack` extension:

```ruby
# Install adminpack extension
edb_extension 'EDBAS pg_buffercache' do
  database 'edb'
  extension 'pg_buffercache'
end
```

### edb_access

This resource uses the accumulator pattern to build up the `pg_hba.conf` file via chef resources instead of piling on a mountain of chef attributes to make this cookbook more reusable. It directly mirrors the configuration options of the `pg_hba.conf` file in the resource and by default notifies the server with a reload to avoid a full restart, causing a potential outage of service. To revoke access, simply remove the resource and the access change won't be computed into the final `pg_hba.conf`

#### Actions

- `grant` - (default) Creates an access line inside of `pg_hba.conf`

#### Properties

Name            | Types  | Description                                                                               | Default           | Required?
--------------- | ------ | ----------------------------------------------------------------------------------------- | ----------------- | ---------
`name`          | String | Name of the access resource, this is left as a comment inside the `pg_hba` config         | Resource name     | yes
`source`        | String | The cookbook template filename if you want to use your own custom template                | 'pg_hba.conf.erb' | yes
`cookbook`      | String | The cookbook to look in for the template source                                           | 'edb'             | yes
`comment`       | String | A comment to leave above the entry in `pg_hba`                                            | nil               | no
`access_type`   | String | The type of access, e.g. local or host                                                    | 'local'           | yes
`access_db`     | String | The database to access. Can use 'all' for all databases                                   | 'all'             | yes
`access_user`   | String | The user accessing the database. Can use 'all' for any user                               | 'all'             | yes
`access_addr`   | String | The address(es) allowed access. Can be nil if method ident is used since it is local then | nil               | no
`access_method` | String | Authentication method to use                                                              | 'ident'           | yes
`notification`  | Symbol | How to notify EPAS of the access change.                                                  | :reload           | yes

#### Examples

To grant access to the enterprisedb user with ident authentication:

```ruby
edb_access 'local_enterprisedb_superuser' do
  comment 'Local enterprisedb superuser access'
  access_type 'local'
  access_db 'all'
  access_user 'enterprisedb'
  access_addr nil
  access_method 'ident'
end
```

This generates the following line in the `pg_hba.conf`:

```
# Local enterprisedb superuser access
local   all             enterprisedb                            ident
```

**Note**: The template by default generates a local access for Unix domain sockets only to support running the SQL execute resources. In EPAS version 9.1 and higher, the method is 'peer' instead of 'ident' which is identical. It looks like this:

```
# "local" is for Unix domain socket connections only
local   all             all                                     peer
```

### edb_ident

This resource generate `pg_ident.conf` configuration file to manage user mapping between system and EPAS users.

#### Actions

- `create` - (default) Creates an mapping line inside of `pg_ident.conf`

#### Properties

Name           | Types       | Description                                                                | Default             | Required?
-------------- | ----------- | -------------------------------------------------------------------------- | ------------------- | ---------
`mapname`      | String      | Name of the user mapping                                                   | Resource name       | yes
`source`       | String      | The cookbook template filename if you want to use your own custom template | 'pg_ident.conf.erb' | no
`cookbook`     | String      | The cookbook to look in for the template source                            | 'edb'               | no
`comment`      | String, nil | A comment to leave above the entry in `pg_ident`                           | nil                 | no
`system_user`  | String      | System user or regexp used for the mapping                                 | None                | yes
`pg_user`      | String      | Pg user or regexp used for the mapping                                     | None                | yes
`notification` | Symbol      | How to notify EPAS of the access change.                                   | :reload             | no

#### Examples

Creates a `mymapping` mapping that map `john` system user to `user1` EPAS user:

```ruby
edb_ident 'Map john to user1' do
  comment 'John Mapping'
  mapname 'mymapping'
  system_user 'john'
  pg_user 'user1'
end
```

This generates the following line in the `pg_ident.conf`:

```
# MAPNAME       SYSTEM-USERNAME         PG-USERNAME

# John Mapping
mymapping       john                    user1
```

To grant access to the foo user with password authentication:

```ruby
edb_access 'local_foo_user' do
  comment 'Foo user access'
  access_type 'host'
  access_db 'all'
  access_user 'foo'
  access_addr '127.0.0.1/32'
  access_method 'md5'
end
```

This generates the following line in the `pg_hba.conf`:

```
# Local enterprsiedb superuser access
host   all             foo               127.0.0.1/32           ident
```

### edb_database

This resource manages EPAS databases.

#### Actions

- `create` - (default) Creates the given database.
- `drop` - Drops the given database.

#### Properties

Name       | Types   | Description                                                         | Default             | Required?
---------- | ------- | ------------------------------------------------------------------- | ------------------- | ---------
`database` | String  | Name of the database to create                                      | Resource name       | yes
`user`     | String  | User which run psql command                                         | 'enterprisedb'      | no
`template` | String  | Template used to create the new database                            | 'template1'         | no
`host`     | String  | Define the host server where the database creation will be executed | Not set (localhost) | no
`port`     | Integer | Define the port of EPAS server                                      | 5444                | no
`encoding` | String  | Define database encoding                                            | 'UTF-8'             | no
`locale`   | String  | Define database locale                                              | 'en_US.UTF-8'       | no
`owner`    | String  | Define the owner of the database                                    | Not set             | no

#### Examples

To create database named 'my_app' with owner 'user1':

```ruby
edb_database 'my_app' do
  owner 'user1'
end
```

### edb_user

This resource manage EPAS users.

#### Actions

- `create` - (default) Creates the given user with default or given privileges.
- `update` - Update user privilieges.
- `drop` - Deletes the given user.

#### Properties

Name                 | Types   | Description                                     | Default | Required?
-------------------- | ------- | ----------------------------------------------- | ------- | ---------
`user`               | String  | User to create                                  |         | Yes
`superuser`          | Boolean | Define if user needs superuser role             | false   | no
`createdb`           | Boolean | Define if user needs createdb role              | false   | no
`createrole`         | Boolean | Define if user needs createrole role            | false   | no
`inherit`            | Boolean | Define if user inherits the privileges of roles | true    | no
`replication`        | Boolean | Define if user needs replication role           | false   | no
`login`              | Boolean | Define if user can login                        | true    | no
`password`           | String  | Set user's password                             |         | no
`encrypted_password` | String  | Set user's password with an hashed password     |         | no
`valid_until`        | String  | Define an account expiration date               |         | no

#### Examples

Create an user `user1` with a password, with `createdb` role and set an expiration date to 2018, Dec 21.

```ruby
edb_user 'user1' do
  password 'UserP4ssword'
  createdb true
  valid_until '2018-12-31'
end
```

## Usage

To install and configure your EPAS instance you need to create your own cookbook and call needed resources with your own parameters.

More examples can be found in `test/cookbooks/test/recipes`

## Example Usage

Example: cookbooks/edb/recipes/default.rb

```ruby
edb_client_install 'EPAS Client' do
  setup_repo false
  version '9.6'
end

edb_server_install 'EPAS Server' do
  version '9.6'
  setup_repo false
  password 'P0sgresP4ssword'
end

edb_server_conf 'EPAS Config' do
  notification :reload
end
```

## Known issues
1. As of July 2018, creation of extensions is not fully supported

## Contributing

Please refer to each project's style guidelines and guidelines for submitting patches and additions. In general, we follow the "fork-and-pull" Git workflow.

1. **Fork** the repo on GitHub
2. **Clone** the project to your own machine
3. **Commit** changes to your own branch
4. **Push** your work back up to your fork
5. Submit a **Pull request** so that we can review your changes

NOTE: Be sure to merge the latest from "upstream" before making a pull request!

[Contribution informations for this project] (CONTRIBUTING.md)

## License

Copyright 2010-2017, Chef Software, Inc.

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
