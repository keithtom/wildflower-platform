module V1
  class UserSerializer < ApplicationSerializer
    attributes :email, :is_admin

    attribute :first_name do |user|
      if person = user.person
        person.first_name
      end
    end

    attribute :last_name do |user|
      if person = user.person
        person.last_name
      end
    end

    attribute :has_password do |user|
      user.password.present?
    end

    attribute :image_url do |user|
      if person = user.person
        if person.profile_image.attached?
          signed_id = person.signed_id(expires_in: 1.hour)
          Rails.application.routes.url_helpers.v1_person_profile_image_url(
            person_id: person.external_identifier, signed_id:
          )
        elsif person.image_url.present?
          person.image_url
        end
      end
    end

    belongs_to :person, serializer: V1::PersonBasicSerializer, id_method_name: :external_identifier do |user|
      user.person
    end

    attribute :ssj do |user|
      person = user.person
      ssj_team = person&.ssj_team
      ssj_team = person.ssj_team_members.first&.ssj_team if person && ssj_team.nil?
      if person && ssj_team
        workflow = ssj_team.workflow
        {
          currentPhase: workflow.current_phase,
          expectedStartDate: ssj_team.expected_start_date,
          workflowId: workflow.external_identifier,
          teamId: ssj_team.external_identifier
        }
      end
    end

    attribute :schools do |user|
      person = user.person
      school_relationships = person&.school_relationships
      if person && school_relationships.length > 0
        school_relationships
          .select { |sr| [School::Status::OPEN, School::Status::EMERGING].include?(sr.school.status) }
          .map do |sr|
            {
              id: sr.school&.external_identifier,
              name: sr.school&.name,
              workflowId: sr.school&.workflow&.external_identifier, # DEPRECATE
              workflowIds: sr.school&.workflows&.visible&.map(&:external_identifier),
              affiliated: sr.school&.affiliated,
              start_date: sr.start_date,
              end_date: sr.end_date,
              role_list: sr.role_list
            }
          end
      end
    end
  end
end
