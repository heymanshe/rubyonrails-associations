class Book < ApplicationRecord
  belongs_to :author
  # , class_name: "Patron"
end

# To update a specific column
# class Book < ApplicationRecord
#   belongs_to :author, touch: :books_updated_at
# end
