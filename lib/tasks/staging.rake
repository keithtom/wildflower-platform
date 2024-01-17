namespace :staging do
  desc 'Seed initial users'
  task initialize: :environment do
    daniela = User.find_or_create_by!(email: "daniela.vasan@wildflowerschools.org") do |user|
      user.password = "password"
    end
    daniela.person || (daniela.person = Person.create!(email: "daniela.vasan@wildflowerschools.org", first_name: "Daniela", last_name: "Vasan", image_url: "https://files.slack.com/files-pri/T1BCRBEKF-F056GR2P6L9/headshot2.jpg"))
    daniela.save!

    sunny = User.find_or_create_by!(email: "sunny.greenberg@wildflowerschools.org") do |user|
      user.password = "password"
    end
    sunny.person || (sunny.person = Person.create!(email: "sunny.greenberg@wildflowerschools.org", first_name: "Sunny", last_name: "Greenberg", image_url: "https://files.slack.com/files-pri/T1BCRBEKF-F0563MTR3L1/sunny_greenberg_mid-atlantic_region.jpeg"))
    sunny.save!

    users = [
      { email: "anedd28@gmail.com",
        first_name: "Adassa",
        last_name: "Brutus",
      },
      { email: "maggie.paulin@wildflowerschools.org",
        first_name: "Maggie",
        last_name: "Paulin",
      },
      { email: "taylor@littleuniverse.com",
        first_name: "Taylor",
        last_name: "Zanke",
      },
      { email: "li.ouyang@wildflowerschools.org",
        first_name: "Li",
        last_name: "Ouyang",
      },  
      { email: "keith.tom@wildflowerschools.org",
        first_name: "Keith",
        last_name: "Tom",
      }
    ]

    users.each do |user|
      user = User.find_or_create_by!(email: user[:email]) do |user|
        user.password = "password"
      end
      if !user.person
        user.person = Person.create!(email: user[:email], first_name: user[:first_name], last_name: user[:last_name])
        user.save!
      end

      workflow_instance = workflow_definition.instances.create!
      SSJ::Initialize.run(workflow_instance.id)
      team = user.person.ssj_team || user.person.ssj_team = SSJ::Team.create!(workflow: workflow_instance)
      team.ops_guide = sunny.person
      team.regional_growth_lead = daniela.person
      team.save!
      user.save!
      
      SSJ::TeamMember.create! ssj_team: team, person: user.person, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE
      SSJ::TeamMember.create! ssj_team: team, person: daniela.person, role: SSJ::TeamMember::RGL, status: SSJ::TeamMember::ACTIVE
      SSJ::TeamMember.create! ssj_team: team, person: sunny.person, role: SSJ::TeamMember::OPS_GUIDE, status: SSJ::TeamMember::ACTIVE
    end
  end
  
  desc 'Cleanup test fixtures'
  task delete_test_fixtures: :environment do
    User.where("lower(email) like ? OR lower(email) like ?", "cypress_test%", "newemail%").each do |user|
      begin
        person = user&.person
        user&.destroy! 
        if person
          person.address&.destroy!
          person.profile_image&.purge
          person.school_relationships.each do |school_relationship|
            school_relationship.destroy!
          end
          person.schools.each do |school|
            school.destroy!
          end

          if ssj_team = person.ssj_team
            ssj_team.ops_guide_id = nil
            ssj_team.regional_growth_lead_id = nil
            ssj_team.save!

            ssj_team.team_members.each do |team_member|
              unless team_member.person&.email&.include?("wildflower")
                User.where(person_id: team_member.person_id).destroy_all
                team_member.person&.destroy!
              end
              team_member.destroy!
            end
            ssj_team.destroy!
        
            workflow_instance = ssj_team.workflow
            workflow_instance.processes.each do |process|
              process.steps.each do |step|
                step.assignments.each do |assignment|
                  assignment.destroy!
                end
                step.destroy!
              end
              process.destroy!
            end
            workflow_instance.destroy!
          end
        end
      rescue => e
        Rails.logger.error("Unable to detroy user record and associated records for id #{user.id}: #{e.message}")
      end
    end
  end
end
