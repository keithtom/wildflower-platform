# Workflow

Workflow is a general tool for managing work done by a group of people towards an end goal.

Workflows
Processes
Steps
Dependencies

Definitions vs instances
Definitions are the template.
In definition land, processes are stand alone.  A library of processes.
You build up a workflow by selecting processes and dependencies.

In instances, you track:
1) real work progress: assignment, completion by people.
2) manual steps: deviations from expected work plans
3) performance concerns

Many definitiosn
many instances

Feedback loops for authors to iterate on workflow.

Step is where you get the work done.

In general, we should view the workflows as being instantiated from events that trigger the requirement of a workflow.
Examples:
1) a user joins the SSJ; instantiate an SSJ workflow

## Workflow in the SSJ

Workflow should not be coupled to the SSJ.
You can imagine workflow powering many internal operations tasks for the foundation or running a school or the advice process.



## Design Decisions 

A lot of requirements are pre-dominantly from the SSJ.

`step.complete` is useful for determining  completeness of the step for dependency calculations.
Completion is a concept that is tied to a user (e.g. a step can be completed by one or more users).
But for dependency purposes, we made the assumption that we only care if 1 person has completed it for dependency purposes.
In the front-end, complete cares about which user complete and that's a different concept.