module Workflow
  class Definition::Step < ApplicationRecord
    belongs_to :process
    has_many :documents, as: :documentable
    has_many :instances, class_name: 'Workflow::Instance::Step', foreign_key: 'definition_id'
  end
end
