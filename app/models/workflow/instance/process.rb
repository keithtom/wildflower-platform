module Workflow
  class Instance::Process < ApplicationRecord
    include ApplicationRecord::ExternalIdentifier

    acts_as_paranoid
    audited

    belongs_to :definition, class_name: 'Workflow::Definition::Process', optional: true # for manual steps
    belongs_to :workflow

    has_many :workable_dependencies, class_name: 'Workflow::Instance::Dependency', as: :workable
    has_many :prerequisites, through: :workable_dependencies, source: :prerequisite_workable, source_type: 'Workflow::Instance::Process'

    has_many :prerequisite_dependencies, class_name: 'Workflow::Instance::Dependency', as: :prerequisite_workable
    has_many :postrequisites, through: :prerequisite_dependencies, source: :workable, source_type: 'Workflow::Instance::Process'

    has_many :steps

    acts_as_taggable_on :categories, :phase

    enum completion_status: { unstarted: 0, started: 2, finished: 3 }
    enum dependency_cache: { prerequisites_unmet: 0, prerequisites_met: 1}

    scope :by_position, -> { order('workflow_instance_processes.position ASC') }
    scope :within_timeframe, ->(date) { where('? BETWEEN suggested_start_date AND due_date', date) }
    scope :past_due, -> { where('due_date < ? AND completion_status != ?', Time.zone.today, completion_statuses[:finished]) }

    def completed?
      !!self.completed_at
    end

    def assigned_and_incomplete?
      steps.incomplete.includes(:assignments).detect { |s| s.assignments.any? }
    end
  end
end
