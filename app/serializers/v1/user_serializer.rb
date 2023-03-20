module V1
  class UserSerializer < ApplicationSerializer
    attributes :email

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
        person.image_url
      end
    end

    attribute :hub do |user|
      if person = user.person
        person&.hub&.name
      end
    end

    belongs_to :person, serializer: V1::PersonSerializer, id_method_name: :external_identifier do |user|
      user.person
    end

    attribute :ssj do |user|
      if person = user.person
        ssj_team = person.ssj_team
        workflow = ssj_team.workflow
        {
          currentPhase: workflow.current_phase,
          opsGuide: V1::PersonSerializer.new(ssj_team.ops_guide),
          regionalGrowthLead: V1::PersonSerializer.new(ssj_team.regional_growth_lead)
        }
      end
    end
  end
end
