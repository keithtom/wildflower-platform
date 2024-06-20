## THings that need to be updated
# 1. Initializers
# .   - probably shoudl rename it from SSJ to something more general?
# 2. A way to know if processes need to be re-upped?
# 3.

# should we run the job every month? No, should run it once every school year. Since it looks like
# the user wants to view tasks in the future

Process::Definition::Process.where(recurring: true).each do |process_def|
  process_def.instances.group(:workflow_id).order('created_at DESC').each do |process_instance|
    last_due_date = process_instance.due_date
    new_due_date = last_due_date + Workflow::Definition::Process.recurring_types[process_def.recurring_type].months
  end
end