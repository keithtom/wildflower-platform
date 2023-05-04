namespace :staging do
  desc 'Seed initial users'
  task initialize: :environment do
    daniela = User.find_or_create_by!(email: "daniela.vasan@wildflowerschools.org") do |user|
      user.password = "password"
    end
    daniela.person || (daniela.person = Person.create!(email: "daniela.vasan@wildflowerschools.org", first_name: "Daniela", last_name: "Vasan", image_url: "https://files.slack.com/files-pri/T1BCRBEKF-F056GR2P6L9/headshot2.jpg"))

    sunny = User.find_or_create_by!(email: "sunny.greenberg@wildflowerschools.org") do |user|
      user.password = "password"
    end
    sunny.person || (sunny.person = Person.create!(email: "sunny.greenberg@wildflowerschools.org", first_name: "Sunny", last_name: "Greenberg", image_url: "https://files.slack.com/files-pri/T1BCRBEKF-F0563MTR3L1/sunny_greenberg_mid-atlantic_region.jpeg"))

    adassa = User.find_or_create_by!(email: "anedd28@gmail.com") do |user|
      user.password = "password"
    end
    adassa.person || (adassa.person = Person.create!(email: "anedd28@gmail.com", first_name: "Adassa", last_name: "Brutus"))
    adassa.person.gender = "Female"
    adassa.person.lgbtqia = false
    adassa.person.save!
    adassa.save!
    
    workflow_definition = Workflow::Definition::Workflow.last
    workflow_instance = SSJ::Initialize.run(workflow_definition)

    team = adassa.person.ssj_team || adassa.person.ssj_team = SSJ::Team.create!(workflow: workflow_instance)
    
    team.ops_guide = sunny.person
    team.regional_growth_lead = daniela.person
    SSJ::TeamMember.create! ssj_team: team, person: adassa.person, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE
    SSJ::TeamMember.create! ssj_team: team, person: daniela.person, role: SSJ::TeamMember::RGL, status: SSJ::TeamMember::ACTIVE
    SSJ::TeamMember.create! ssj_team: team, person: sunny.person, role: SSJ::TeamMember::OPS_GUIDE, status: SSJ::TeamMember::ACTIVE

    team.expected_start_date = Date.parse("1/1/2024")

    team.save!

    maggie = User.find_or_create_by!(email: "maggie.paulin@wildflowerschools.org") do |user|
      user.password = "password"
    end
    maggie.person || (maggie.person = Person.create!(email: "maggie.paulin@wildflowerschools.org", first_name: "Maggie", last_name: "Paulin"))
    workflow_instance = SSJ::Initialize.run(workflow_definition)
    maggie_team = maggie.person.ssj_team || maggie.person.ssj_team = SSJ::Team.create!(workflow: workflow_instance)
    maggie_team.ops_guide = sunny.person
    maggie_team.regional_growth_lead = daniela.person
    maggie_team.save!
    SSJ::TeamMember.create! ssj_team: maggie_team, person: maggie.person, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE
    SSJ::TeamMember.create! ssj_team: maggie_team, person: daniela.person, role: SSJ::TeamMember::RGL, status: SSJ::TeamMember::ACTIVE
    SSJ::TeamMember.create! ssj_team: maggie_team, person: sunny.person, role: SSJ::TeamMember::OPS_GUIDE, status: SSJ::TeamMember::ACTIVE
  end
end
