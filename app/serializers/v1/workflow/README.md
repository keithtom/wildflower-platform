# README

This application only deals with workflow instances.
We must know what version to stamp new workflows out with; so we need to get access to a definition; or at least initialize a new instance for a user.
Update state on that workflow:
  Update conditional data context
  We mark steps complete.
  Mark steps uncomplete.
  We read/watch/make decisions via enter form data.
  Add manual steps.
See the current workflow for my user or team.

- decision question:
  - do we stamp out the entire workflow...
  - or do we leave a reference to the definition?  (this let's maggie do on the fly changes)
  - does adding a step to a completed process "uncomplete" that process?
     - how do we let users know about notificaitons that had gone off? is that a formal concept?

Workflow definitions are defined elsewhere.
