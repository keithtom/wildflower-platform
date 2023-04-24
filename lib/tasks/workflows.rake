require 'ssj/workflow/import'

namespace :workflows do
  desc 'import workflow definitions from spreadsheet'
  task initialize: :environment do
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

    ssj_team = SSJ::Team.create! workflow: workflow_instance
    SSJ::TeamMember.create(person: person1, ssj_team: ssj_team, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE)
    SSJ::TeamMember.create(person: person2, ssj_team: ssj_team, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE)
  
    puts "creating 50 teams with sensible, default workflow"
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
  end
end