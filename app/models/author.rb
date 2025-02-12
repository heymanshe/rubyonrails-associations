class Author < ApplicationRecord
  # has_many :books, dependent: :destroy
  has_many :books, before_add: :check_credit_limit

  def check_credit_limit(book)
    throw(:abort) if limit_reached?
  end
end

# class Author < ApplicationRecord
#   has_many :books, before_add: :check_credit_limit, after_add: :log_addition,
#                    before_remove: :confirm_removal, after_remove: :log_removal

#   def check_credit_limit(book)
#     if limit_reached?
#       puts "Cannot add book: Credit limit reached!"
#       throw(:abort) # Prevent book from being added
#     end
#   end

#   def log_addition(book)
#     puts "Book '#{book.title}' was added to author #{self.name}."
#   end

#   def confirm_removal(book)
#     puts "Preparing to remove book '#{book.title}' from author #{self.name}."
#   end

#   def log_removal(book)
#     puts "Book '#{book.title}' was removed from author #{self.name}."
#   end

#   def limit_reached?
#     books.count >= 2 # Example: Allow only 2 books per author
#   end
# end

# module BookExtensions
#   def find_by_prefix(prefix)
#     where("title LIKE ?", "#{prefix}%")
#   end

#   def recent_books
#     where("created_at > ?", 5.days.ago)
#   end
# end

# class Author < ApplicationRecord
#   has_many :books, -> { extending BookExtensions }
# end
