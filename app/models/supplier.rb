class Supplier < ApplicationRecord
  has_one :account, foreign_key: "supp_id"
  has_one :account_history, through: :account
end
