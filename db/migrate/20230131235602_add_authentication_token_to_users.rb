class AddAuthenticationTokenToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :authentication_token, :string, limit: 30
    add_index :users, :authentication_token, unique: true
    add_column :users, :authentication_token_at, :datetime
  end
end
