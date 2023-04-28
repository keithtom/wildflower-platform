# Models

## Primary Models

These models are the ones that will likely be reused across the entire platform.
For example, the SSJ is one sub-application of the entire WF platform.  SSJ specific models belong in the SSJ namespace.  But people and schools will be used across the SSJ, advice process, directory etc.

The top level folder contains mostly the models related to the `Wildflower Network`, which is the core platform that connects all the sub-applications.  The main entities are `Person` and `School` with the other models providing a supporting relationship.

### Major Namespaces

1. `SSJ` - These models hold data specific to an ETLs journey through the School Startup Journey.  The SSJ makes heavy use of the workflow system but it is an independent system.

2. `Workflow` - These models should be domain agnostic.  They persist all the data related to workflows, processes, steps, dependencies for definitions and instances.  The instances also contain additional logic for manual steps, assignment/completion.

3. `Advice` - These models relate to the Advice Process product.  They hold all data related to a decision and stakeholders as they move through the process.


## Why Person class and not TeacherLeader class?
I specifically chose Person over something more specific like TeacherLeader because ETLs become TLs become Operations Guides and become Foundation Partners.  So people speak of them as separate groups but they really are roles that people hold.

