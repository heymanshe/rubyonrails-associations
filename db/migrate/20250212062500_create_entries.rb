class CreateEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :entries do |t|
      t.string :entryable_type
      t.integer :entryable_id

      t.timestamps
    end
  end
end
