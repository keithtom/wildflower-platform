# definition, version, it contains the state of completed steps.
# so you know all the processes (they have state? cached?)
# so has all the steps
  - assignee
  - started_at
  - completed_at
  - role
  - see commands...
  - has manual steps
  - also has a user id, every user has their own instance of the definition with state
    - so there's a external_data_state
    - ask maggie: users can never change the dependencies? just add new ones for manual
    -


# Workflow State
- which user
- its context data? just a JSON hash.

# Process State

# Step State


## Concerns
- workable, (startable/completeable), (conditionable)
  - (undoing work is different)
  - ideally, we re-issue work, even as a manual task.  but maybe having an email that goes out to tell ppl to disregard is useful.
  - 
