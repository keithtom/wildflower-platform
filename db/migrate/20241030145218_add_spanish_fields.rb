class AddSpanishFields < ActiveRecord::Migration[7.0]
  def change
    add_column :workflow_definition_processes, :title_es, :string
    add_column :workflow_definition_processes, :description_es, :text
    add_column :workflow_definition_steps, :title_es, :string
    add_column :workflow_definition_steps, :description_es, :text
    add_column :workflow_definition_steps, :decision_question_es, :string
    add_column :documents, :title_es, :string
    add_column :workflow_decision_options, :description_es, :string

    add_column :workflow_instance_processes, :title_es, :string
    add_column :workflow_instance_processes, :description_es, :text
    add_column :workflow_instance_steps, :title_es, :string
    add_column :workflow_instance_steps, :description_es, :text
    add_column :workflow_instance_steps, :decision_question_es, :string
  end
end