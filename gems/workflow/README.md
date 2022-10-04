# Workflow

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

## Usage
How to use my plugin.


- Currently keeping presentation logic like serializers into host app
- this app holds
  - data models
  - commands/services for core actions (should really be exposed as an api or callable code...)
  - background jobs for all the domain agnostic hooks
  - it was gonna hold the workflow author UI (admin UI) but that's just a spreadsheet for now
    - eventually UI will need to be more smart.
  - the views to do the actual work need to be hosted elsewhere
    - read (link to content, iframe), watch/listen: youtube videos
    - form input
      - eventually the conditionally is coupled to the data model
      - build a language for the primitives that we are conditional on
      - then we need a data mapping from host application which meets API (when doing any workflow action, we need to give the instance's conditional context...)

## Installation
Add this line to your application's Gemfile:

```ruby
gem "workflow"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install workflow
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
