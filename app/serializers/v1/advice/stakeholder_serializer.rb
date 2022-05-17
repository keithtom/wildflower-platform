class V1::Advice::StakeholderSerializer < ApplicationSerializer
  attributes :name, :email, :phone, :calendar_url, :roles, :subroles, :status

  belongs_to :decision, serializer: V1::Advice::DecisionSerializer, id_methodname: :external_identifier

  # we would serialize messages as part of a general api but not needed for now
  # has_many :messages, serializer: V1::Advice::MessageSerializer, id_methodname: :external_identifier
  # has_many :records
  
  # use last record's status
  attribute :status do |obj|
    obj.records.order("created_at DESC").first&.status
  end

  attribute :last_activity do |obj, params|
    params[:activities].last
  end

  has_many :activities do |obj, params|
    params[:activities]
  end
end
