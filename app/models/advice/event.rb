# A log of events of interest for a particular decision
class Advice::Event < ApplicationRecord
  belongs_to :decision
  belongs_to :originator, polymorphic: true # either the creator or Stakeholder
end
