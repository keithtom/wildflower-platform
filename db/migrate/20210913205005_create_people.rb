class CreatePeople < ActiveRecord::Migration[6.1]
  def change
    create_table :people do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :phone

      t.string :journey_state  # paused, ETL, TL, OG, WF

      # race data
      # marketing data, lead object.
      # SSJ data.

      t.timestamps
    end

    # connected to a school, one active, other passive.
    # current and former roles.
    # stage, passive vs paused exploration etc.

    # personal data, address, race
    # marketing data, referal source

    # SSJ data?
    # assigned partners (SSJ)

    # we have such broad tables... many sources coming together from many purposes...
    # you should be able to "join" in the SSJ data set.
    # skills list...

    # advanced options
    # flexible tuition, charter, etc

    add_index :people, :email, unique: true
  end
end
