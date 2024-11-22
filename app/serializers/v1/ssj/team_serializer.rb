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

  has_many :partners, serializer: V1::PersonBasicSerializer, id_method_name: :external_identifier do |team|
    team.partners.active
  end

  attribute :ops_guide do |team|
    ops_guide = team.ops_guide
    if ops_guide.nil?
      nil
    else
      {
        firstName: ops_guide.first_name,
        lastName: ops_guide.last_name,
        email: ops_guide.email,
        phone: ops_guide.phone,
        imageUrl: image_url(ops_guide)
      }
    end
  end

  attribute :regional_growth_lead do |team|
    rgl = team.regional_growth_lead
    if rgl.nil?
      nil
    else
      {
        firstName: rgl.first_name,
        lastName: rgl.last_name,
        email: rgl.email,
        phone: rgl.phone,
        imageUrl: image_url(rgl)
      }
    end
  end
end
