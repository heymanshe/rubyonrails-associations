class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.string :title
      t.datetime :published_at
      t.references :author, index: true, foreign_key: true

      t.timestamps
    end
  end
end
