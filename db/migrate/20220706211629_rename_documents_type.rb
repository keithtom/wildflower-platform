class RenameDocumentsType < ActiveRecord::Migration[7.0]
  def change
    rename_column :documents, :type, :inheritance_type
  end
end
