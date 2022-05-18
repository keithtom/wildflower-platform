# A log of events of interest for a particular decision
class Advice::Event < ApplicationRecord
  # "draft", open, amend, close
  STAKEHOLDER_OPENED = "stakeholder opened"

  belongs_to :decision
  belongs_to :originator, polymorphic: true # either the creator or Stakeholder
end
