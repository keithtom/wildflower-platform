# Requirements

This is not an exhaustive list of requirements but highlights the "trickier" or potentially unexpected design decisions.


## Workflow: Multiple assignees, completers and selected options.

Originally, the system was designed to have 1 assignee and completer per step.
Since the work is meant to be done as a team of 2 ETLs for the SSJ, we discovered later on that Maggie doesn't want the system to suggest that only 1 TL needs to complete certain tasks, usually related to learning - for example, "Learn about the advice process".

We inventoried these step types and came up with 2 dominant types:
1. individual tasks - meant to be completed by each TL
2. collaborative tasks - meaning many TLs can work on them, but only 1 TL is required to complete it for it to be considered done for both of them.

This lead to refactoring out data related to assignment and completion (selected options) from `Step` to `StepAssignment`.

The dependency tree of workflow still only focuses on `Process` and `Step`, however we track assignment and completion separately.

This avoids the more complicated question of "is a step complete?" becoming "is this step complete by this person?".
We have `Step#assigned?` and `Step#completed?` for maintaining the simple interface for purposes of the UI and the backend dependency logic.

This means that if we have process A, and it is filled with individual steps, and TL1 completes all steps but TL2 does not, process A will be considered complete for the team when it comes to process dependencies.

Slack convo: https://wildflowerschools.slack.com/archives/C043E307JPK/p1680552823175679?thread_ts=1680551682.669959&cid=C043E307JPK