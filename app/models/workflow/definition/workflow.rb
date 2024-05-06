module Workflow
  class Definition::Workflow < ApplicationRecord
    acts_as_paranoid
    audited

    has_many :selected_processes
    has_many :processes, through: :selected_processes # these are the nodes

    has_many :steps, through: :processes

    has_many :dependencies # this loads the dependency edges

    has_many :instances, class_name: 'Workflow::Instance::Workflow', foreign_key: 'definition_id'
    
    belongs_to :previous_version, class_name: 'Workflow::Definition::Workflow', foreign_key: 'previous_version_id', optional: true
    has_one :next_version, class_name: 'Workflow::Definition::Workflow', foreign_key: 'previous_version_id'

    scope :latest_versions, -> { select('DISTINCT ON (name) *').order('name, version DESC') }

    validate :name_version_combo, on: :create
    validate :check_published, on: :update

    def published?
      !published_at.nil?
    end
  
    def displayed_processes
      if published?
        processes.where.not("workflow_definition_selected_processes.state = ?", 'removed')
      else
        processes
      end
    end
  
    private

    def check_published
      if published? && (name_changed? || version_changed? || description_changed? )
        errors.add(:base, "updates to name, description or version can only be made if unpublished")
      end
    end
  
    def name_version_combo
      if Workflow::Definition::Workflow.where(name: name, version: version, deleted_at: nil).exists?
        errors.add(:base, "name and version combination must be unique for non-deleted records")
      end
    end
  end
end
