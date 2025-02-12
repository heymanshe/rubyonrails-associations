class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { where(active: true) }
end

# Filters records based on conditions -> { where(factory: "Seattle") }
