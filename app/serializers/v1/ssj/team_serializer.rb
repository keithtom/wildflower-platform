class V1::Ssj::TeamSerializer < ApplicationSerializer
  # method override
  def serializable_hash
    {
      hasPartner: has_partner?(@resource),
      team: @resource.map{|person| V1::PersonSerializer.new(person, { include: ['schools', 'school_relationships', 'address']})}
    }
  end

  private

  def has_partner?(resource)
    resource.count > 1
  end
end
