class V1::SSJ::TeamSerializer < ApplicationSerializer
  # method override
  def serializable_hash
    {
      hasPartner: has_partner?(@resource),
      invitedPartner: @resource.partner_members.invited.count > 0,
      expectedStartDate: @resource.expected_start_date,
      team: V1::PersonSerializer.new(@resource.partners.active.includes(:schools, :school_relationships, :address, :taggings, :profile_image_attachment), { include: ['schools', 'school_relationships', 'address'] })
    }
  end

  private

  def has_partner?(resource)
    resource.partners.count > 1 # yourself is 1 partner.
  end
end
