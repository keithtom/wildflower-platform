class V1::Advice::DecisionSerializer < ApplicationSerializer
  attributes :state, :title, :context, :proposal, :decide_by, :advice_by,
    :role, :final_summary, :created_at, :updated_at

  belongs_to :creator, serializer: V1::PersonSerializer, id_methodname: :external_identifier

  has_many :stakeholders, serializer: V1::Advice::StakeholderSerializer, id_methodname: :external_identifier

  has_many :documents, serializer: V1::DocumentSerializer, id_methodname: :external_identifier

  # we would serialize messages as part of a general api but not needed for now
  # has_many :messages, serializer: V1::Advice::MessageSerializer, id_methodname: :external_identifier

  # last activity for this decision.  alwys put.
  attribute :last_activity do |obj, params|
    if params[:activities_grouped_by_decision]
      V1::Advice::ActivitySerializer.new(params[:activities_grouped_by_decision][obj.id]&.first)
    end
  end
end
