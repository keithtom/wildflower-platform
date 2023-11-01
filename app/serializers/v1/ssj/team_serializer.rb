class V1::SSJ::TeamSerializer < ApplicationSerializer
  attributes :expected_start_date, :temp_name
  
  attribute :has_partner do |team|
    team.partners.count > 1
  end
  
  attribute :invited_partner do |team|
    team.partner_members.invited.count > 0
  end
  
  has_many :partners, serializer: V1::PersonSerializer ,id_method_name: :external_identifier do |team|
    team.partners.active
  end
end
