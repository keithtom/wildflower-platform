module Workflow
  class Definition::Process < ApplicationRecord
    DEFAULT_INCREMENT = 100

    acts_as_paranoid
    audited

    RECURRING_TYPES = [
      ANNUALLY = 'annually'.freeze,
      ANNUALLY_MONTH_SPECIFIC = 'annually_month_specific'.freeze,
      QUARTERLY = 'quarterly'.freeze,
      SUMMER = 'summer'.freeze,
      MONTHLY = 'monthly'.freeze
    ].freeze

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
    has_one :next_version, class_name: 'Workflow::Definition::Workflow', foreign_key: 'previous_version_id'

    before_destroy :validate_destroyable
    before_save :validate_recurring

    def published?
      !published_at.nil?
    end

    def recurring_type
      return nil unless recurring

      case duration
      when 1
        if due_months.length == 1
          ANNUALLY_MONTH_SPECIFIC
        else
          MONTHLY
        end
      when 2
        SUMMER
      when 3
        QUARTERLY
      when 12
        ANNUALLY
      else
        if Rails.env.production?
          SlackClient.chat_postMessage(channel: '#circle-platform', text: 'OSC Warning: unknown duration to calculate recurring_type', as_user: true)
        end
      end
    end

    private

    def validate_destroyable
      if instances.count > 0
        errors.add(:base, "Cannot destroy process with existing instances")
        throw(:abort)
      end
    end
  
    def validate_recurring
      return true if previous_version.nil?

      if recurring? && !previous_version.recurring?
        errors.add(:base, "Cannot be recurring if previous version is not")
        throw(:abort)
      end

      if !recurring? && previous_version.recurring?
        errors.add(:base, "Must be recurring if previous version is")
        throw(:abort)
      end
    end
  end
end
