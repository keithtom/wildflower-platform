class CreateTeacherLeaders < ActiveRecord::Migration[6.1]
  def change
    create_table :teacher_leaders do |t|

      t.timestamps
    end
  end
end
