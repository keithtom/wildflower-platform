# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require 'factory_bot_rails'
#
# ['Massachusetts',
# 'Minnesota',
# 'Puerto Rico',
# 'New York',
# 'New Jersey',
# 'Pennsylvania',
# 'Washington, D.C.',
# 'North Carolina',
# 'Northern California',
# 'Colorado',
# 'Emerging'].each do |hub_name|
#   Hub.create!(name: hub_name, :entrepreneur => FactoryBot.create(:person))
# end

# general context
hub1 = FactoryBot.create(:hub)
hub2 = FactoryBot.create(:hub)

pod1 = FactoryBot.create(:pod, hub: hub1)
school1 = FactoryBot.create(:school, :pod => pod1)
school1.address = FactoryBot.create(:address)

# two teacher leaders for school 1
person1 = FactoryBot.create(:person)
person2 = FactoryBot.create(:person)

user1 = FactoryBot.create(:user, :person => person1, email: "test@test.com", password: "password")
user2 = FactoryBot.create(:user, :person => person2, email: "test2@test.com", password: "password")

person1.audience_list = "primary, elementary"
person1.role_list = "marketing, operations, teacher leader"
person1.address = FactoryBot.create(:address)
person1.school_relationships << FactoryBot.create(:school_relationship, school: school1)
person1.save!

person2.audience_list = "charter, foundation"
person2.role_list = "compliance, communications, finance, teacher leader"
person2.address = FactoryBot.create(:address)
person2.school_relationships << FactoryBot.create(:school_relationship, school: school1)
person2.save!

# new ETL
person3 = FactoryBot.create(:person)
user3 = FactoryBot.create(:user, :person => person3)
pod3 = FactoryBot.create(:pod, hub: hub2)
school3 = FactoryBot.create(:school)
school3.address = FactoryBot.create(:address)

# ops guide
ops_guide = FactoryBot.create(:person)

# new discovery user
user3 = FactoryBot.create(:user)  # hasn't yet associated personal profile yet

# basic workflow
workflow_definition = FactoryBot.create(:workflow_definition_workflow, name: "Basic Workflow")

# Visioning
process1 = FactoryBot.create(:workflow_definition_process, title: "Milestone A")
3.times { |i| FactoryBot.create(:workflow_definition_step, process: process1, title: "Step #{i+1}", position: i*Workflow::Definition::Step::DEFAULT_INCREMENT) }

process2 = FactoryBot.create(:workflow_definition_process, title: "Milestone B-1", position: 200)
1.times { |i| FactoryBot.create(:workflow_definition_step, process: process2, title: "Step #{i+1}", position: i*Workflow::Definition::Step::DEFAULT_INCREMENT) }

process3 = FactoryBot.create(:workflow_definition_process, title: "Milestone B-2", position: 300)
2.times { |i| FactoryBot.create(:workflow_definition_step, process: process3, title: "Step #{i+1}", position: i*Workflow::Definition::Step::DEFAULT_INCREMENT) }

[process1, process2, process3].each_with_index do |process, i|
  workflow_definition.processes << process

  process.position = i*Workflow::Definition::Process::DEFAULT_INCREMENT
  process.phase_list = ::SSJ::Phase::VISIONING
  process.category_list = ::SSJ::Category::CATEGORIES[i]
  process.save!
end
workflow_definition.dependencies.create! workable: process3, prerequisite_workable: process2

# Planning
process4 = FactoryBot.create(:workflow_definition_process, title: "Milestone C")
2.times { |i| FactoryBot.create(:workflow_definition_step, process: process4, title: "Step #{i+1}", position: i*Workflow::Definition::Step::DEFAULT_INCREMENT) }

process5 = FactoryBot.create(:workflow_definition_process, title: "Milestone C-X")
1.times { |i| FactoryBot.create(:workflow_definition_step, process: process5, title: "Collaborative Step #{i+1}", completion_type: Workflow::Definition::Step::ONE_PER_GROUP, position: i*Workflow::Definition::Step::DEFAULT_INCREMENT) }

process6 = FactoryBot.create(:workflow_definition_process, title: "Milestone C-Y")
2.times { |i| FactoryBot.create(:workflow_definition_step, process: process6, title: "Step #{i+1}", position: i*Workflow::Definition::Step::DEFAULT_INCREMENT) }

[process4, process5, process6].each_with_index do |process, i|
  workflow_definition.processes << process

  process.position = i*Workflow::Definition::Process::DEFAULT_INCREMENT
  process.phase_list = ::SSJ::Phase::PLANNING
  process.category_list = ::SSJ::Category::CATEGORIES[i+3]
  process.save!
end
workflow_definition.dependencies.create! workable: process5, prerequisite_workable: process4
workflow_definition.dependencies.create! workable: process6, prerequisite_workable: process4

# Startup
process7 = FactoryBot.create(:workflow_definition_process, title: "Milestone D")
1.times { |i| FactoryBot.create(:workflow_definition_step, process: process7, title: "Step #{i+1}", position: i*Workflow::Definition::Step::DEFAULT_INCREMENT) }

process8 = FactoryBot.create(:workflow_definition_process, title: "Milestone E")
1.times { |i| FactoryBot.create(:workflow_definition_step, process: process8, title: "Step #{i+1}", position: i*Workflow::Definition::Step::DEFAULT_INCREMENT) }

process9 = FactoryBot.create(:workflow_definition_process, title: "Milestone D-E-F")
2.times { |i| FactoryBot.create(:workflow_definition_step, process: process9, title: "Collaborative Step #{i+1}", completion_type: Workflow::Definition::Step::ONE_PER_GROUP, position: i*Workflow::Definition::Step::DEFAULT_INCREMENT) }

[process7, process8, process9].each_with_index do |process, i|
  workflow_definition.processes << process

  process.position = i*Workflow::Definition::Process::DEFAULT_INCREMENT
  process.phase_list = ::SSJ::Phase::STARTUP
  process.category_list = ::SSJ::Category::CATEGORIES[i]
  process.save!
end
workflow_definition.dependencies.create! workable: process9, prerequisite_workable: process7
workflow_definition.dependencies.create! workable: process9, prerequisite_workable: process8

# create user, person x 2
# create team, create team members
# instantiate workflow
instance = SSJ::Initialize.run(workflow_definition)
# assign to team.
team = SSJ::Team.find(2)
team.update(workflow: instance)

# create a workflow instance
# c502-4f84 hardcode
# and hardcode user for test@  "aef6-b33b"
workflow_instance = SSJ::Initialize.run(workflow_definition)

# then i can assign things and see todo list. as well as process show.

# SSJ Team
ssj_team = SSJ::Team.create! workflow: workflow_instance
SSJ::TeamMember.create!(person: person1, ssj_team: ssj_team, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE)
SSJ::TeamMember.create!(person: person2, ssj_team: ssj_team, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE)
SSJ::TeamMember.create!(person: ops_guide, ssj_team: ssj_team, role: SSJ::TeamMember::OPS_GUIDE, status: SSJ::TeamMember::ACTIVE)

# Create many of theses
50.times do |i|
  person1 = FactoryBot.create(:person)
  person2 = FactoryBot.create(:person)

  user1 = FactoryBot.create(:user, :person => person1, email: "test#{(i+1)*2+1}@test.com", password: "password")
  user2 = FactoryBot.create(:user, :person => person2, email: "test#{(i+2)*2}@test.com", password: "password")

  workflow_instance = SSJ::Initialize.run(workflow_definition)
  ssj_team = SSJ::Team.create! workflow: workflow_instance
  SSJ::TeamMember.create(person: person1, ssj_team: ssj_team, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE)
  SSJ::TeamMember.create(person: person2, ssj_team: ssj_team, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE)
end