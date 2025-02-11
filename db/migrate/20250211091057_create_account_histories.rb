class CreateAccountHistories < ActiveRecord::Migration[8.0]
  def change
    unless table_exists?(:suppliers)
      create_table :suppliers do |t|
        t.string :name
        t.timestamps
      end
    end


    create_table :accounts do |t|
      t.belongs_to :supplier, null: false, foreign_key: true
      t.string :account_number
      t.timestamps
    end

    create_table :account_histories do |t|
      t.belongs_to :account, null: false, foreign_key: true
      t.integer :credit_rating
      t.timestamps
    end
  end
end
