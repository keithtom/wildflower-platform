# A log of messages from a stakeholder or the creator.
class Advice::Message < ApplicationRecord
  belongs_to :decision
  belongs_to :sender, polymorphic: true # either the creator or Stakeholder
end
