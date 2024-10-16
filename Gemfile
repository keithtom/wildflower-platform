# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.0'

gem 'rails', '~> 7.0.8'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.6'

#authentication
gem 'devise'
gem 'devise-jwt'
gem 'devise-token_authenticatable'

# Use Puma as the app server
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Use Active Storage variant
gem 'image_processing', '~> 1.2'

# Code Organization
gem 'simple_command'

# Build JSON APIs
gem 'jsonapi-serializer'
gem 'rack-cors'
gem 'oj' # faster serialization

# Search
gem "searchkick"
gem "elasticsearch", '~> 7.x'
gem "will_paginate", "~> 3.3.0"

# models
gem 'acts-as-taggable-on'
gem 'aasm'

# highlight.io
gem 'highlight_io'

# parsing addresses
gem 'Indirizzo', require: "indirizzo"

gem "audited"

# airtable
gem "airrecord"

# Use good_job for background jobs
gem 'good_job'

# soft deletion
gem 'acts_as_paranoid'

# slack client
gem 'slack-ruby-client'

group :development, :test do
  gem 'dotenv-rails'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'guard-rspec'
  gem 'rspec-its' # consider removing this...
  gem 'rspec-rails'

  # APIs
  gem 'jsonapi-rspec'

  gem 'database_cleaner-active_record'
  gem 'bullet'
end

gem 'factory_bot_rails' # move to development after initial testing done; needed for production seeding
gem 'faker'

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'listen', '~> 3.3'
  gem 'rack-mini-profiler', '~> 2.0'

  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false

  gem 'rails-erd'
end

group :production do

  # for ActiveStorage
  gem 'aws-sdk-s3', require: false

end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
