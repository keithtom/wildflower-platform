class V1::SSJ::TeamSerializer < ApplicationSerializer
  # method override
  def serializable_hash
    {
      hasPartner: has_partner?(@resource),
      expectedStartDate: @resource.expected_start_date,
      team: @resource.people.active.map{|person| V1::PersonSerializer.new(person, { include: ['schools', 'school_relationships', 'address']})}
    }
  end

  private

  def has_partner?(resource)
    resource.people.partners.active.count > 1
  end
end
