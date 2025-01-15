class AddExpectedStartDateToSchool < ActiveRecord::Migration[7.0]
  def change
    add_column :schools, :expected_start_date, :date
  end
end
