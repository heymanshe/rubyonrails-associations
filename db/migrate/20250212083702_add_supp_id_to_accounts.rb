class AddSuppIdToAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :supp_id, :integer
    add_foreign_key :accounts, :suppliers, column: :supp_id
  end
end
