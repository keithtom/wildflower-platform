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

## Assumptions
# a school year goes from Sept to August

# Initialization
# i have a process definition
# .  - check the suggested timeframe
# .  - copy over instance and create suggested timeframe based on the current year
school_year_start_month = 9
school_year_end_month = 8

today = DateTime.now
school_year_start = today.month < 9 ? today.year - 1 : today.year
school_year_end = school_year_start + 1

process_definition.suggested_timeframes => [month]
# this would create 12 months worth of TODOs, even past ones
process_definition.suggested_timeframes.each do |month|
  year = month < 9 ? school_year_start : school_year_end
  new_due_date = DateTime.new(year, month, 1).end_of_month
  process_definition.instances.create!(due_date: new_due_date)
end

#specs
# previous month
today month: 3
timeframe month: 2
=> same year

# previous month, when in the fall
today month: 9
timeframe: 3
=> next year

# future month in the fall
today month: 3
timeframe month: 9
=> previous year

# monthly recurring
process_def.suggested_timeframes => [9, 10, 11, 12, 1, 2, 3, 4, 5, 6, 7, 8]
# quarterly recurring
process_def.suggested_timeframes => [9, 12, 3, 6]
# annually recurring
process_def.suggested_timeframes => [8]

# sort months to start with september and end in august
sorted_months = months.sort do |a, b|
  [(a < 9 ? a + 12 : a), (b < 9 ? b + 12 : b)].reduce(:<=>)
end

# how do we create TODOs based off of year end?
process_definition.suggested_timeframes.each do |month|

end

# past date from previous calendar year
today: 3
suggested_timeframe: 9
=> do not create process instance


# past date from current calendar year
today: 3
suggested_timeframe: 1
=> do not create process instance

# same month
today: 3
suggested_timeframe: 3
=> create process instance

# future month from same school and calendar year
today: 3
suggested_timeframe: 8
=> create process instance

# future month from same calendar year but next school year
today: 3
suggested_timeframe: 10
=> Do not create process instance