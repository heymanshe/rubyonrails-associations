class CreatePictures < ActiveRecord::Migration[8.0]
  def change
    create_table :pictures do |t|
      t.string :name, null: false
      t.belongs_to :imageable, polymorphic: true, index: true
      t.timestamps
    end
  end
end
