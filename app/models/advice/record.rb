# The final record for each stakeholder on a decision
class Advice::Record < ApplicationRecord
  NO_OBJECTION = "no objection"
  OBJECTION = "objection"
  NO_OPINION = "no opinion"
  NO_TIME = "no time"


  belongs_to :decision
  belongs_to :stakeholder
end
