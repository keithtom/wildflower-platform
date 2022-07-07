class V1::Advice::StakeholderSerializer < ApplicationSerializer
  attributes :name, :email, :phone, :calendar_url, :roles, :subroles, :status

  belongs_to :decision, serializer: V1::Advice::DecisionSerializer, id_method_name: :external_identifier do |stakeholder|
    stakeholder.decision
  end

  # we would serialize messages as part of a general api but not needed for now
  # has_many :messages, serializer: V1::Advice::MessageSerializer, id_method_name: :external_identifier
  # has_many :records

  # use last record's status
  attribute :status do |obj|
    obj.records.order("created_at DESC").first&.status
  end

  attribute :last_activity do |obj, params|
    if params[:activities_grouped_by_stakeholder]
       V1::Advice::ActivitySerializer.new(params[:activities_grouped_by_stakeholder][obj.id]&.first)
     end
  end

  attribute :activities do |obj, params|
    if params[:activities_grouped_by_stakeholder]
      V1::Advice::ActivitySerializer.new(params[:activities_grouped_by_stakeholder][obj.id])
    else
      []
    end
  end
end
