class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.string :subject
      t.string :body

      t.timestamps
    end
  end
end
