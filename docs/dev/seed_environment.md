# Seed Environment

## Helpful rake tasks
Run in the following order, since the second one destroys any existing workflow definitions.

1. `rake db:seed` creates some users, people, schools, hubs
2. `rake workflows:import_default` destroys any existing workflow definitions, and import definition from Maggie's spreadsheet. Creates some SSJ teams instantiated with it.
3. `rake workflows:create_dummy` creates a dummy workflow definitino and creates 50 ssj teams instantiated with it.