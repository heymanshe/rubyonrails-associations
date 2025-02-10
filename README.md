# Overview 

- Active Record associations define relationships between models.
- Associations are set up using macro-style calls like `has_many`, `belongs_to`, etc.
- Rails handles primary and foreign key relationships between models automatically.
- This simplifies common operations, improves readability, and helps in managing related data easily.

# 1. 1. Active Record Associations

- Define relationships between models.

- Implemented as macro-style calls (e.g., `has_many` `:comments`).

- Helps manage data effectively, making operations simpler.

- Rails defines & manages Primary Key (PK) and Foreign Key (FK) relationships.

- Provides useful methods for working with related data.

## 1.1 Without Associations

+ Migration for Authors & Books

```ruby
class CreateAuthors < ActiveRecord::Migration[8.0]
  def change
    create_table :authors do |t|
      t.string :name
      t.timestamps
    end

    create_table :books do |t|
      t.references :author
      t.datetime :published_at
      t.timestamps
    end
  end
end
```

+ Models Without Associations

```ruby
class Author < ApplicationRecord
end

class Book < ApplicationRecord
end
```

+ Creating a Book (Manual FK Assignment)

```bash
@book = Book.create(author_id: @author.id, published_at: Time.now)

Deleting an Author & Their Books (Manual Cleanup)

@books = Book.where(author_id: @author.id)
@books.each do |book|
  book.destroy
end
@author.destroy
```

## 1.2 Using Associations

+ Updated Models with Associations

```ruby
class Author < ApplicationRecord
  has_many :books, dependent: :destroy
end

class Book < ApplicationRecord
  belongs_to :author
end
```

+ Creating a Book (Simplified)

```bash
@book = @author.books.create(published_at: Time.now)
```

+ Deleting an Author & Their Books (Automated Cleanup)

```bash
@author.destroy
```

+ Migration for Foreign Key

```bash
rails generate migration AddAuthorToBooks author:references
```

+ Adds `author_id` column.

+ Sets up FK relationship in the database.
