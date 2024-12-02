class V1::SSJ::TeamSerializer < ApplicationSerializer
  include V1::Imageable

  attributes :expected_start_date, :temp_name, :temp_location

  attribute :workflow_id do |team|
    team.workflow&.external_identifier
  end

  attribute :current_phase do |team|
    team.workflow&.current_phase
  end

  attribute :has_partner do |team|
    team.partners.count > 1
  end

  attribute :invited_partner do |team|
    team.partner_members.invited.count > 0
  end

  has_many :partners, serializer: V1::PersonCardSerializer, id_method_name: :external_identifier do |team|
    team.partners.active
  end

  belongs_to :ops_guide, serializer: V1::PersonCardSerializer, id_method_name: :external_identifier do |team|
    team.ops_guide
  end

  belongs_to :regional_growth_lead, serializer: V1::PersonCardSerializer, id_method_name: :external_identifier do |team|
    team.regional_growth_lead
  end
end
