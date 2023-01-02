class AddJtiToUses < ActiveRecord::Migration[7.0]
  def up
    add_column :users, :jti, :string
    User.all.each do |user|
      user.jti = SecureRandom.uuid
      user.save
    end
    change_column :users, :jti, :string, null: false
    add_index :users, :jti, unique: true
  end

  def down
    remove_column :users, :jti
  end
end
