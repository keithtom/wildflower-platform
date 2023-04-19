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
#   Hub.create!!(name: hub_name, :entrepreneur => FactoryBot.create!(:person))
# end

# general context
hub1 = FactoryBot.create!(:hub)
hub2 = FactoryBot.create!(:hub)

# two teacher leaders for school 1
person1 = FactoryBot.create!(:person)
person2 = FactoryBot.create!(:person)

user1 = FactoryBot.create!(:user, :person => person1, email: "test@test.com", password: "password")
user2 = FactoryBot.create!(:user, :person => person2, email: "test2@test.com", password: "password")

pod1 = FactoryBot.create!(:pod, hub: hub1)
school1 = FactoryBot.create!(:school, :pod => pod1)
school1.address = FactoryBot.create!(:address)

person1.audience_list = "primary, elementary"
person1.role_list = "marketing, operations, teacher leader"
person1.address = FactoryBot.create!(:address)
person1.school_relationships << FactoryBot.create!(:school_relationship, school: school1)
person1.save!

person2.audience_list = "charter, foundation"
person2.role_list = "compliance, communications, finance, teacher leader"
person2.address = FactoryBot.create!(:address)
person2.school_relationships << FactoryBot.create!(:school_relationship, school: school1)
person2.save!


# new ETL
person3 = FactoryBot.create!(:person)
user3 = FactoryBot.create!(:user, :person => person3)
pod3 = FactoryBot.create!(:pod, hub: hub2)
school3 = FactoryBot.create!(:school)
school3.address = FactoryBot.create!(:address)

# new discovery user
user3 = FactoryBot.create!(:user)  # hasn't yet associated personal profile yet

# basic workflow
workflow_definition = FactoryBot.create!(:workflow_definition_workflow)
process1 = FactoryBot.create!(:workflow_definition_process, workflow: workflow_definition, title: "Milestone 1")
process2 = FactoryBot.create!(:workflow_definition_process, workflow: workflow_definition, title: "Milestone 2")

# need to put these into phases.
# 1 for visoning, 2 for planning, 3 for startup

# add some basic categories 
# steps factory should create resources

3.times do |i|
  FactoryBot.create!(:workflow_definition_step, process: process1, title: "Step #{i}")
end

2.times do |i|
  FactoryBot.create!(:workflow_definition_step, process: process2, title: "Step #{i}")
end

# create a workflow instance
# c502-4f84 hardcode
# and hardcode user for test@  "aef6-b33b"
workflow_instance = SSJ::Initialize.run(workflow_definition)

# then i can assign things and see todo list. as well as process show.

# SSJ Team
ssj_team = SSJ::Team.create! workflow: workflow_instance
SSJ::TeamMember.create!(person: person1, ssj_team: team, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE)
SSJ::TeamMember.create!(person: person2, ssj_team: team, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE)
