class CreateAdviceStakeholders < ActiveRecord::Migration[7.0]
  def change
    create_table :advice_stakeholders do |t|
      t.belongs_to :decision
      t.belongs_to :person, index: false

      t.string :external_name
      t.string :external_email
      t.string :external_phone
      t.string :external_calendar_url
      t.string :external_roles
      t.string :external_subroles

      t.timestamps
    end
  end
end
