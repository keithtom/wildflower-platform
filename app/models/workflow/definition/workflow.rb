module Workflow
  class Definition::Workflow < ApplicationRecord
    audited

    has_many :selected_processes
    has_many :processes, through: :selected_processes # these are the nodes

    has_many :steps, through: :processes

    has_many :dependencies # this loads the dependency edges

    has_many :instances, class_name: 'Workflow::Instance::Workflow', foreign_key: 'definition_id'
    
    belongs_to :previous_version, class_name: 'Workflow::Definition::Workflow', foreign_key: 'previous_version_id', optional: true
    has_one :next_version, class_name: 'Workflow::Definition::Workflow', foreign_key: 'previous_version_id'

    scope :latest_versions, -> { select('DISTINCT ON (name) *').order('name, version DESC') }

    validates :name, uniqueness: { scope: :version, message: "and version combination must be unique" }
    validate :check_published, on: :update

    def published?
      !published_at.nil?
    end
  
    private

    def check_published
      if published_was && (name_changed? || version_changed? || description_changed? )
        errors.add(:base, "Updates to name, description or version can only be made if unpublished")
      end
    end
  end
end
