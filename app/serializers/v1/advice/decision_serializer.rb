class V1::Advice::DecisionSerializer < ApplicationSerializer
  attributes :state, :title, :context, :proposal, :links, :decide_by, :advice_by,
    :role, :final_summary, :created_at, :updated_at

  belongs_to :creator, serializer: V1::PersonSerializer, id_methodname: :external_identifier

  has_many :stakeholders

  # has an activity feed.  do we need to expose messages on their own?
  # put more logic in backend.

  has_many :messages
  has_many :events
  has_many :records
end
