module Workflow
  class Definition::Process < ApplicationRecord
    DEFAULT_INCREMENT = 100
    
    acts_as_paranoid
    audited

    enum recurring_type: { monthly: 12, quarterly: 4, annual: 1 }

    has_many :instances, class_name: 'Workflow::Instance::Process', foreign_key: 'definition_id'

    has_many :steps
    accepts_nested_attributes_for :steps

    has_many :selected_processes
    has_many :workflows, through: :selected_processes
    accepts_nested_attributes_for :selected_processes

    has_many :workable_dependencies, class_name: 'Workflow::Definition::Dependency', as: :workable
    has_many :prerequisites, through: :workable_dependencies, source: :prerequisite_workable, source_type: 'Workflow::Definition::Process'
    accepts_nested_attributes_for :workable_dependencies

    has_many :prerequisite_dependencies, class_name: 'Workflow::Definition::Dependency', as: :prerequisite_workable
    has_many :postrequisites, through: :prerequisite_dependencies, source: :workable, source_type: 'Workflow::Definition::Process'

    acts_as_taggable_on :categories, :phase

    belongs_to :previous_version, class_name: 'Workflow::Definition::Process', foreign_key: 'previous_version_id', optional: true
    has_one :next_version, class_name: 'Workflow::Definition::Process', foreign_key: 'previous_version_id'

    # TODO: can we query for this in another way?
    belongs_to :previous_recurring, class_name: 'Workflow::Definition::Process', foreign_key: 'previous_recurring_id', optional: true
    has_one :next_recurring, class_name: 'Workflow::Definition::Process', foreign_key: 'previous_version_id'

    before_destroy :validate_destroyable

    def published?
      !published_at.nil?
    end

    def occurrences_in_a_year
      return 1 unless recurring?

      Workflow::Definition::Process.recurring_types[recurring_type]
    end

    def next_due_date
      return nil unless recurring?


    end

    private

    def validate_destroyable
      if instances.count > 0
        errors.add(:base, "Cannot destroy process with existing instances")
        throw(:abort)
      end
    end
  end
end
