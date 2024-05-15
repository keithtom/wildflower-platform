class V1::SSJ::TeamSerializer < ApplicationSerializer
  attributes :expected_start_date, :temp_name
  
  attribute :workflow_id do |team|
    team.workflow&.external_identifier
  end

  attribute :current_phase do |team|
    team.workflow&.current_phase
  end

  attribute :has_partner do |team|
    team.partners.count > 1
  end
  
  attribute :temp_location do |team, params|
    if params[:team_id]
      team.temp_location
    end
  end
  
  attribute :invited_partner do |team|
    team.partner_members.invited.count > 0
  end
  
  has_many :partners, serializer: V1::PersonSerializer ,id_method_name: :external_identifier do |team, params|
    if params[:team_id]
      team.partners.active
    end
  end
end
