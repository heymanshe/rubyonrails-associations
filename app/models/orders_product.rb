class OrdersProduct < ApplicationRecord
  self.primary_keys = :order_id, :product_id  # Define composite keys explicitly

  belongs_to :order
  belongs_to :product
end
