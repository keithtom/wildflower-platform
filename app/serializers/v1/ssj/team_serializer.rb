class V1::SSJ::TeamSerializer < ApplicationSerializer
  # method override
  def serializable_hash
    {
      hasPartner: has_partner?(@resource),
      expectedStartDate: @resource.expected_start_date,
      team: V1::PersonSerializer.new(@resource.people.active, { include: ['schools', 'school_relationships', 'address'] })
    }
  end

  private

  def has_partner?(resource)
    resource.partners.active.count > 1 # yourself is 1 partner.
  end
end
