class Entry < ApplicationRecord
  delegated_type :entryable, types: %w[Message Comment], dependent: :destroy
  delegate :title, to: :entryable
end
