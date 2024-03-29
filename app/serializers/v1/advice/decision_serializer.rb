class V1::Advice::DecisionSerializer < ApplicationSerializer
  attributes :state, :title, :context, :proposal, :decide_by, :advice_by,
    :role, :final_summary, :created_at, :updated_at

  belongs_to :creator, serializer: V1::PersonSerializer, id_method_name: :external_identifier do |decision|
    decision.creator
  end

  has_many :stakeholders, id_method_name: :external_identifier do |decision|
    decision.stakeholders
  end

  has_many :documents, serializer: V1::DocumentSerializer, id_method_name: :external_identifier do |decision|
    decision.documents
  end

  # we would serialize messages as part of a general api but not needed for now
  # has_many :messages, serializer: V1::Advice::MessageSerializer, id_method_name: :external_identifier

  # last activity for this decision.  alwys put.
  attribute :last_activity do |obj, params|
    if params[:activities_grouped_by_decision]
      V1::Advice::ActivitySerializer.new(params[:activities_grouped_by_decision][obj.id]&.first)
    end
  end
end
