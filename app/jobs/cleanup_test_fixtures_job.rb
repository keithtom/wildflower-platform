# frozen_string_literal: true

class CleanupTestFixturesJob < ActiveJob::Base
  queue_as :default

  def perform
    Person.where('lower(email) like ? OR lower(email) like ?', 'cypress_test%', 'newemail%').limit(500).each do |person|
      user = User.find_by(person_id: person.id)
      user&.destroy_fully!
      if person
        person.address&.destroy_fully!
        person.profile_image&.purge
        person.school_relationships.each do |school_relationship|
          school_relationship.destroy_fully!
        end
        person.schools.each do |school|
          if workflow_instance = school.workflow
            workflow_instance.processes.each do |process|
              process.steps.each do |step|
                step.assignments.each do |assignment|
                  assignment.destroy_fully!
                end
                step.destroy_fully!
              end
              process.destroy_fully!
            end
            workflow_instance.destroy!
          end
          school.destroy_fully!
        end

        if ssj_team = person.ssj_team
          ssj_team.ops_guide_id = nil
          ssj_team.regional_growth_lead_id = nil
          ssj_team.save!

          ssj_team.team_members.each do |team_member|
            unless team_member.person&.email&.include?('wildflower')
              User.where(person_id: team_member.person_id).destroy_all
              team_member.person&.destroy_fully!
            end
            team_member.destroy_fully!
          end
          ssj_team.destroy_fully!

          workflow_instance = ssj_team.workflow
          workflow_instance.processes.each do |process|
            process.steps.each do |step|
              step.assignments.each do |assignment|
                assignment.destroy!
              end
              step.destroy_fully!
            end
            process.destroy_fully!
          end
          workflow_instance.destroy_fully!
        end
      end
      person.destroy_fully!
      Rails.logger.info('Successfully completed cleaning up test fixtures')
    rescue StandardError => e
      Rails.logger.error("Unable to detroy user record and associated records for id #{user.id}: #{e.message}")
    end
    School.where(name: 'Cypress Test School').each do |school|
      school.school_relationships.destroy_all
      school.destroy!
    end
  end
end
