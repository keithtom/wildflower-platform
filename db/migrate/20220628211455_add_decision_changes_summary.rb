class AddDecisionChangesSummary < ActiveRecord::Migration[7.0]
  def change
    add_column :advice_decisions, :changes_summary, :text
  end
end
