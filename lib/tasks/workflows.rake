require 'ssj/workflow/import'
require_relative '../../app/models/s_s_j.rb'

namespace :workflows do
  desc 'destroy all workflow definitions, import new definitions from spreadsheet and create 50 ssj teams with workflows defined by import'
  task import_default: :environment do
    abort 'Cannot destroy all and import into production' if Rails.env.production?
    puts "destroying all workflows and importing new ones"
    create_default_workflow_and_processes

    puts "instantiating imported workflow"
    workflow_definition = Workflow::Definition::Workflow.last
    workflow_instance = SSJ::Initialize.run(workflow_definition)

    puts "setting test users' workflow to instantiated workflow"
    user1 = User.find_or_create_by!(email: 'test@test.com')
    if user1.person.nil?
      user1.person = FactoryBot.create!(:person)
      user1.save!
    end
    user2 = User.find_or_create_by!(email: 'test2@test.com')
    if user2.person.nil?
      user2.person = FactoryBot.create!(:person)
      user2.save!
    end

    ops_guide = FactoryBot.create(:person, role_list: "ops_guide")
    ssj_team = SSJ::Team.create!(workflow: workflow_instance, ops_guide_id: ops_guide.id)
    SSJ::TeamMember.create(person: user1.person, ssj_team: ssj_team, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE)
    SSJ::TeamMember.create(person: user2.person, ssj_team: ssj_team, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE)
    SSJ::TeamMember.create(person: ops_guide, ssj_team: ssj_team, role: SSJ::TeamMember::OPS_GUIDE, status: SSJ::TeamMember::ACTIVE)
  
    puts "creating 50 teams with sensible, default workflow"
    datestamp = DateTime.now.to_i
    50.times do |i|
      print "."
      person1 = FactoryBot.create(:person)
      person2 = FactoryBot.create(:person)
      person3 = FactoryBot.create(:person)
    
      user1 = FactoryBot.create(:user, :person => person1, email: "test_#{datestamp}_#{(i+1)*2+1}@test.com", password: "password")
      user2 = FactoryBot.create(:user, :person => person2, email: "test_#{datestamp}_#{(i+2)*2}@test.com", password: "password")
    
      workflow_instance = SSJ::Initialize.run(workflow_definition)
      ssj_team = SSJ::Team.create!(workflow: workflow_instance, ops_guide_id: person3.id)
      SSJ::TeamMember.create(person: person1, ssj_team: ssj_team, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE)
      SSJ::TeamMember.create(person: person2, ssj_team: ssj_team, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE)
      SSJ::TeamMember.create(person: person3, ssj_team: ssj_team, role: SSJ::TeamMember::OPS_GUIDE, status: SSJ::TeamMember::ACTIVE)
    end
  end

  desc 'create dummy workflow and processes with ssj teams'
  task create_dummy: :environment do
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
    
    # Create many of theses
    datestamp = DateTime.now.to_i
    50.times do |i|
      print "."
      person1 = FactoryBot.create(:person)
      person2 = FactoryBot.create(:person)
    
      user1 = FactoryBot.create(:user, :person => person1, email: "test_#{datestamp}_#{(i+1)*2+1}@test.com", password: "password")
      user2 = FactoryBot.create(:user, :person => person2, email: "test_#{datestamp}_#{(i+2)*2}@test.com", password: "password")
    
      workflow_instance = SSJ::Initialize.run(workflow_definition)
      ssj_team = SSJ::Team.create! workflow: workflow_instance
      SSJ::TeamMember.create(person: person1, ssj_team: ssj_team, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE)
      SSJ::TeamMember.create(person: person2, ssj_team: ssj_team, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE)
    end
  end

  ## rails workflows:invite email=li.ouyang@gmail.com ops_guide_email=ray_tillman@mitchell.net
  ## take a user's and ops guide's emails as an argument, and invite them to join an SSJ workflow
  desc 'invite new user'
  task invite_user: :environment do
    email = ENV['email']
    abort 'Must provide an email address' if email.blank?
    ops_guide_email = ENV['ops_guide_email']
    abort 'Must provide an ops guide email address' if ops_guide_email.blank?

    user = User.find_or_create_by!(email: email)
    SSJ::InviteUser.run(user, ops_guide_email)
    puts "invited #{email} to SSJ workflow"
  end
end