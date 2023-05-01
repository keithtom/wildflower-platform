require 'ssj/workflow/import'

namespace :workflows do
  desc 'destroy all workflow definitions, import new definitions from spreadsheet and create 50 ssj teams with workflows defined by import'
  task import_default: :environment do
    abort 'Cannot destroy all and import into production' if Rails.env.production? && ENV['DISABLE_DATABASE_ENVIRONMENT_CHECK'].blank?
    puts "destroying all workflows and importing new ones"
    create_default_workflow_and_processes

    puts "instantiating imported workflow"
    workflow_definition = Workflow::Definition::Workflow.last
    workflow_instance = SSJ::Initialize.run(workflow_definition)

    puts "setting test users' workflow to instantiated workflow"
    user1 = User.find_or_create_by!(email: 'test@test.com')
    if user1.person.nil?
      user1.password = "password"
      user1.person = FactoryBot.create!(:person)
      user1.save!
    end
    user2 = User.find_or_create_by!(email: 'test2@test.com')
    if user2.person.nil?
      user2.password = "password"
      user2.person = FactoryBot.create!(:person)
      user2.save!
    end

    ops_guide = FactoryBot.create(:person, role_list: "ops_guide")
    ssj_team = SSJ::Team.create!(workflow: workflow_instance, ops_guide_id: ops_guide.id)
    SSJ::TeamMember.create(person: user1.person, ssj_team: ssj_team, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE)
    SSJ::TeamMember.create(person: user2.person, ssj_team: ssj_team, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE)
    SSJ::TeamMember.create(person: ops_guide, ssj_team: ssj_team, role: SSJ::TeamMember::OPS_GUIDE, status: SSJ::TeamMember::ACTIVE)
  
    image_rotation = [
      'https://en.gravatar.com/userimage/4310496/6924cffc6c2e516293c1e8b6e7533ab5.jpg',
      'https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50',
      'https://ca.slack-edge.com/T1BCRBEKF-U044095NSKW-gb71eb8af435-512',
      'https://ca.slack-edge.com/T1BCRBEKF-U6YFWTW67-8c867b8d8fff-512',
      'https://ca.slack-edge.com/T1BCRBEKF-U0431E2ANE6-a196fd3638aa-512',
      'https://ca.slack-edge.com/T1BCRBEKF-UC1RV1LQ5-eb11f16c81c0-192',
    ]

    puts "creating 50 teams with sensible, default workflow"
    50.times do |i|
      print "."
      person1 = FactoryBot.create(:person, image_url: image_rotation[i%image_rotation.length])
      person2 = FactoryBot.create(:person, image_url: image_rotation[i%image_rotation.length])
      person3 = FactoryBot.create(:person, image_url: image_rotation[i%image_rotation.length])
    
      user1 = FactoryBot.create(:user, :person => person1, email: "test#{(i+1)*2+1}@test.com", password: "password")
      user2 = FactoryBot.create(:user, :person => person2, email: "test#{(i+2)*2}@test.com", password: "password")
    
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
    decision_step = FactoryBot.create(:workflow_definition_step, process: process2, title: "Decision Step 1", kind: Workflow::Definition::Step::DECISION, position: Workflow::Definition::Step::DEFAULT_INCREMENT)
    3.times { |i| FactoryBot.create(:workflow_decision_option, decision: decision_step, description: "Option #{i+1}") }
    
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
    decision_step = FactoryBot.create(:workflow_definition_step, process: process5, title: "Collaborative Decision Step 1", kind: Workflow::Definition::Step::DECISION, completion_type: Workflow::Definition::Step::ONE_PER_GROUP, position: Workflow::Definition::Step::DEFAULT_INCREMENT)
    4.times { |i| FactoryBot.create(:workflow_decision_option, decision: decision_step, description: "Option #{i+1}") }
    
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
    
    image_rotation = [
      'https://en.gravatar.com/userimage/4310496/6924cffc6c2e516293c1e8b6e7533ab5.jpg',
      'https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50',
      'https://ca.slack-edge.com/T1BCRBEKF-U044095NSKW-gb71eb8af435-512',
      'https://ca.slack-edge.com/T1BCRBEKF-U6YFWTW67-8c867b8d8fff-512',
      'https://ca.slack-edge.com/T1BCRBEKF-U0431E2ANE6-a196fd3638aa-512',
      'https://ca.slack-edge.com/T1BCRBEKF-UC1RV1LQ5-eb11f16c81c0-192',
    ]

    # Create many of theses
    50.times do |i|
      print "."
      person1 = FactoryBot.create(:person, image_url: image_rotation[i%image_rotation.length])
      person2 = FactoryBot.create(:person, image_url: image_rotation[i%image_rotation.length])
    
      user1 = FactoryBot.create(:user, :person => person1, email: "fake#{(i)*2+1}@test.com", password: "password")
      user2 = FactoryBot.create(:user, :person => person2, email: "fake#{(i+1)*2}@test.com", password: "password")
    
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
    first_name = ENV['first_name']
    abort 'Must provide an email address' if email.blank?
    ops_guide_email = ENV['ops_guide_email']
    abort 'Must provide an ops guide email address' if ops_guide_email.blank?

    user = User.find_or_create_by!(email: email)
    person = Person.find_or_create_by!(email: email)
    person.first_name = first_name
    person.save!
    user.person = person
    user.save!
    SSJ::InviteUser.run(user, ops_guide_email)
    puts "invited #{email} to SSJ workflow"
  end
end