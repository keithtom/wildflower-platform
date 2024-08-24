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

    attribute :image_url do |user|
      if person = user.person
        if person.profile_image.attached?
          Rails.application.routes.url_helpers.rails_blob_url(person.profile_image)
        elsif person.image_url.present?
          person.image_url
        end
      end
    end

    attribute :hub do |user|
      if person = user.person
        person&.hub&.name
      end
    end

    belongs_to :person, serializer: V1::PersonBasicSerializer, id_method_name: :external_identifier do |user|
      user.person
    end

    attribute :ssj do |user|
      person = user.person
      ssj_team = person&.ssj_team
      if person && ssj_team
        workflow = ssj_team.workflow
        {
          currentPhase: workflow.current_phase,
          opsGuide: V1::PersonSerializer.new(ssj_team.ops_guide),
          regionalGrowthLead: V1::PersonSerializer.new(ssj_team.regional_growth_lead),
          expectedStartDate: ssj_team.expected_start_date,
          workflowId: workflow.external_identifier,
          teamId: ssj_team.external_identifier
        }
      end
    end

    attribute :schools do |user|
      person = user.person
      school_relatonships = person&.school_relationships
      if person && school_relatonships.length > 0
        school_relatonships.map do |sr|
          {
            name: sr.school&.name,
            workflowId: sr.school&.workflow&.external_identifier,
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
