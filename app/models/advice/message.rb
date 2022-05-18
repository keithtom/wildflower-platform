# A log of messages from a stakeholder or the creator.
class Advice::Message < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  belongs_to :decision
  belongs_to :sender, polymorphic: true # either the creator or Stakeholder
  belongs_to :stakeholder # really a channel/thread ID
end
