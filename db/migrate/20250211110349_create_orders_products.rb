class CreateOrdersProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :order_products, id: false do |t| # No default primary key
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, default: 1

      t.primary_key [ :order_id, :product_id ]
    end
  end
end
