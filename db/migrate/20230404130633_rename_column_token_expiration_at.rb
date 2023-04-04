class RenameColumnTokenExpirationAt < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :authentication_token_at, :authentication_token_created_at
  end
end
