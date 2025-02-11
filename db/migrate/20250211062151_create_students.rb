class CreateStudents < ActiveRecord::Migration[8.0]
  def change
    create_table :students do |t|
      t.string :name
      t.integer :roll_number
      t.references :teacher, null: false, foreign_key: true

      t.timestamps
    end
  end
end
