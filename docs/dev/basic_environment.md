# Basic Environment

This README will assume you are running on MacOS.

## Installing Ruby & Dependencies

Install `rbenv` with `homebrew`

```console
brew install rbenv
```

Then locally install the right ruby version from the project root,

```console
rbenv install
```

Install the project gems:
```console
bundle
```

## Installing Postgreql

Install Postgresql with homebrew:

```console
brew install postgres
```

Upon successful install, read the instructions for starting your postgres database.


## Initializing your local Rails environment

Get the `config/master.key` secret in a safe and secure manner from a developer.
This is required to decrypt secret environment variables.

Setup your local database and schema:

```console
rake db:create
rake db:migrate
```

## Installing Elasticsearch
1. Install directly from website, by following directions [here](https://www.elastic.co/guide/en/elasticsearch/reference/7.17/targz.html#install-macos). Do not use homebrew.
2. Update the `config/elasticsearch.yml` file such that `xpack.security.enabled` is set to `false`
3. Run `./bin/elasticsearch` from inside the directory
4. Test the server is running correctly by running `curl -X GET "localhost:9200/?pretty"`

## Installing Redis
`brew install redis`
`brew services start redis`