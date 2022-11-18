# README

The instance folder contains the models that represent an instance of one workflow definition.

We copy/instantiate a particular workflow definition by creating objects for each process, step and dependencies.
These objects contain the state of the workflow as the user makes progress through the work.
We maintain completed state of each step/process for example.

A user can also add their own "manual" processes/steps/dependencies to the workflow instance.
A user can also assign work to a person.

The instance always maintains a reference to the definition so we can make "live" updates to the definition.
The author also has the ability to put new changes into the next "version" so changes aren't live and go out with the next version update.



# so has all the steps
  - also has a user id, every user has their own instance of the definition with state
    - so there's a external_data_state
    - ask maggie: users can never change the dependencies? just add new ones for manual
    -

# Workflow State
- which user
- its context data? just a JSON hash.

## Concerns
- workable, (startable/completeable), (conditionable)
  - (undoing work is different)
  - ideally, we re-issue work, even as a manual task.  but maybe having an email that goes out to tell ppl to disregard is useful.
  -
