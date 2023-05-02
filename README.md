# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

## Deployment instructions

Any merge to the `main` branch on the Github repository will automatically deploy to produciton and run migrations.
You can follow the process by using the `heroku logs --tail` command.

### Development Environment

The development host is `https://api-dev.wildflowerschools.org`
Merging to the branch `main` will automatically deploy to this environment.

### Staging Environment

The staging host is `https://api-staging.wildflowerschools.org`.
Merging to the branch `staging` will automatically deploy to this environment.

### Production Environment

The production host is `https://api.wildflowerschools.org`.
Merging to the branch `production` will automatically deploy to this environment.


## Platform API

- Search APIs: people/schools
- show/index
- edit/update
- create

- main entities are people and schools
- school relationships connects the two

- tags are another dimension

## Workflow
If you have a large task that needs to be completed over and over, chances are you need a system that can:
1) break the large task into smaller piece of work
2) manage dependencies between pieces of work; e.g. when can we start on what?

This system aims to do that.

You can have workers (users who do the small pieces of work) be told:
1) what to work on next (based on availability)
2) where are they in the work (in the larger process)
3) see what dependencies are needed for a piece of work
4) see what work is dependent on someone else

When there is changes in the state of the system, you can recompute the new work needed.

If there are work weights, you can project a completion date, or given a completion date, know if you are going to miss.
1) what to work on next (based on urgency)

Workers can add manual tasks to track missing work.

Analytics
- you can see average completion times
- you can see what manual steps are missing
- you can track which workers are working well

### ActiveStorage
Using active storage to manage uploaded profile image's storage and the attachment to the person model. 

The workflow is as such:
- client sends a POST request to `/rails/active_storage/direct_uploads` with some blob information, including checksum
- API creates a blob record in the database and sends back a token, a URL for the client to directly upload the image to, and a `signed_id` to identify the blob
- client then uploads image to the direct URL with the token. API verifies the token is in fact for a blob, and then proceeds to upload to whichever service (production: amazon, local: local). 
- client then updates the person record with the `signed_id` as the `profile_image`

#### Configuration
- `storage.yml` lists the different storage services we use.
- Set which type of service for which environments via the line `config.active_storage.service`
- View aws credentails by running `rails credentials:show` in the terminal.

#### AWS S3
- If you want to test aws locally, change `config.active_storage.service = :local` to `config.active_storage.service = :amazon` in `development.rb`. It should upload to the `ssj-local` bucket setup in S3.
- The client's direct upload url's host will be `https://ssj-local.s3.amazonaws.com`
- Note: If you receive a 403 forbidden error, check the CORS policy in S3. 

### Summary
- this system includes
  - data models
  - commands/services for core actions (should really be exposed as an api or callable code...)
  - background jobs for all the domain agnostic hooks
  - it was gonna include the workflow author UI (admin UI) but that's just a spreadsheet for now
    - eventually UI will need to be more smart.
  - the views to do the actual work need to be hosted elsewhere
    - read (link to content, iframe), watch/listen: youtube videos
    - form input
      - eventually the conditionally is coupled to the data model
      - build a language for the primitives that we are conditional on
      - then we need a data mapping from host application which meets API (when doing any workflow action, we need to give the instance's conditional context...)

