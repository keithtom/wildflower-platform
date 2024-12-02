# frozen_string_literal: true

module WorkflowAttributes
  extend ActiveSupport::Concern

  included do
    private

    def steps_attributes
      [:id, :process_id, :title, :title_es, :description, :description_es, :kind, :position, :completion_type, :min_worktime,
       :max_worktime, :decision_question, :decision_question_es,
       { decision_options_attributes:, documents_attributes: }]
    end

    def decision_options_attributes
      %i[id description description_es]
    end

    def documents_attributes
      %i[id title title_es link]
    end

    def selected_processes_attributes
      %i[id workflow_id position]
    end

    def workable_dependencies_attributes
      %i[id workflow_id prerequisite_workable_type prerequisite_workable_id]
    end

    def process_attributes
      [
        :version, :title, :title_es, :description, :description_es, :phase_list, :recurring, :duration,
        [category_list: []], [due_months: []],
        { steps_attributes:,
          selected_processes_attributes:,
          workable_dependencies_attributes: }
      ]
    end
  end
end
