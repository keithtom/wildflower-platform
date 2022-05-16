# People make decisions and seek out advice from stakeholders.
class Advice::Decision < ApplicationRecord
  DRAFT = "draft"
  OPEN = "open"
  CLOSED = "closed"

  belongs_to :creator, class_name: "Person"

  has_many :stakeholders
  has_many :messages

  has_many :events
  has_many :records
end
