class CreateDocuments < ActiveRecord::Migration[7.0]
  def change
    remove_column :advice_decisions, :links
    create_table :documents do |t|
      t.belongs_to :documentable, polymorphic: true
      t.string :type

      t.string :title
      t.string :link

      t.string :external_identifier, null: false, unique: true

      t.timestamps
    end
  end
end
