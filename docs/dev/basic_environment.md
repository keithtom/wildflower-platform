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

Setup your local database and schema:

```console
rake db:create
rake db:migrate
```
