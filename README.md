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


# 2. Types of Associations

- Rails supports six types of associations, each serving a specific purpose:

`belongs_to`

`has_one`

`has_many`

`has_many :through`

`has_one :through`

`has_and_belongs_to_many`

## 2.1 belongs_to

+ A `belongs_to` association sets up a relationship where each instance of the declaring model "belongs to" one instance of another model. Example:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

- Migration Example:

```ruby
class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :authors do |t|
      t.string :name
      t.timestamps
    end

    create_table :books do |t|
      t.belongs_to :author
      t.datetime :published_at
      t.timestamps
    end
  end
end
```

- The `belongs_to` association ensures a reference column exists in the model's table.

- Using `optional: true` allows the foreign key to be `NULL`.

```ruby
class Book < ApplicationRecord
  belongs_to :author, optional: true
end
```

- Adding a foreign key constraint ensures integrity:

```ruby
create_table :books do |t|
  t.belongs_to :author, foreign_key: true
  # ...
end
```

### 2.1.1 Methods Added by `belongs_to`

- When you declare a `belongs_to` association, the model gains these methods:

**Retrieving the Association**

```bash
@author = @book.author
```

- Force a database reload:

```bash
@author = @book.reload_author
```

- Reset cached association:

```bash
@book.reset_author
```

**Assigning the Association**

```bash
@book.author = @author
```

- Build an association (not saved):

```bash
@author = @book.build_author(name: "John Doe")
```

- Create and save an association:

```bash
@author = @book.create_author(name: "John Doe")
```

- Create and save, raising an error if invalid:

```bash
@book.create_author!(name: "") # Raises ActiveRecord::RecordInvalid
```

**Checking for Association Changes**

```bash
@book.author_changed? # => true if association is updated
@book.author_previously_changed? # => true if previously updated
```

**Checking for Existing Associations**

```bash
if @book.author.nil?
  @msg = "No author found for this book"
end
```

**Saving Behavior**

- Assigning an object to a belongs_to association does not automatically save either the parent or child.

- However, saving the parent object does save the association:

```bash
@book.save
```

### 2.2 2. has_one Association

- A `has_one` association indicates that one other model has a reference to this model. That model can be fetched through this association.

```ruby
class Supplier < ApplicationRecord
  has_one :account
end
```

```ruby
class CreateSuppliers < ActiveRecord::Migration[8.0]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.belongs_to :supplier, index: { unique: true }, foreign_key: true
      t.string :account_number
      t.timestamps
    end
  end
end
```

**Methods Added by `has_one`**

- When declaring a `has_one` association, Rails automatically provides the following methods:

`association`

`association=`

`build_association(attributes = {})`

`create_association(attributes = {})`

`create_association!(attributes = {})`

`reload_association`

`reset_association`

```bash
@supplier.account = @account
@supplier.build_account(terms: "Net 30")
@supplier.create_account(terms: "Net 30")
```

**Checking for Existing Associations**

```bash
if @supplier.account.nil?
  @msg = "No account found for this supplier"
end
```

**Saving Behavior**

- When assigning an object to a `has_one` association, it is automatically saved unless `autosave: false` is used. If the parent object is new, the child objects are saved when the parent is saved.

- Use `build_association` to work with an unsaved object before saving it explicitly.

## 2.3 has_many Association

- A `has_many` association creates a one-to-many relationship where one model can be associated with multiple records of another model.

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :author
end
```

```ruby
class CreateAuthors < ActiveRecord::Migration[6.0]
  def change
    create_table :authors do |t|
      t.string :name
      t.timestamps
    end
  end
end
```

**Methods Added by `has_many`**

`collection`

`collection<<`

`collection.delete`

`collection.destroy`

`collection=, collection.clear`

`collection.empty?` 

`collection.size` 

`collection.count`

`collection.build(attributes = {})`

`collection.create(attributes = {})`

`collection.reload`

## 2.4 has_and_belongs_to_many Association

- A `has_and_belongs_to_many` association creates a direct `many-to-many` relationship between two models without using a separate model for the join table.

```ruby
class User < ApplicationRecord
  has_and_belongs_to_many :groups
end

class Group < ApplicationRecord
  has_and_belongs_to_many :users
end
```

```ruby
class CreateJoinTableUsersGroups < ActiveRecord::Migration[6.0]
  def change
    create_join_table :users, :groups do |t|
      t.index [:user_id, :group_id]
      t.index [:group_id, :user_id]
    end
  end
end
```

**Methods Added by `has_and_belongs_to_many`**

`collection`

`collection<<`

`collection.delete`

`collection.destroy`

`collection=, collection.clear`

`collection.empty?, collection.size, collection.count`

`collection.build(attributes = {})`

`collection.create(attributes = {})`

`collection.reload`

- This type of association is best used when a simple join table is sufficient without needing extra attributes in the join table. If more attributes are needed, a `has_many :through` association is recommended.


# 4. Advanced Associations

## 4.1 Polymorphic Associations

- Polymorphic associations allow a model to belong to multiple other models through a single association. This is useful when a model needs to be linked to different types of models.

```ruby
class Picture < ApplicationRecord
  belongs_to :imageable, polymorphic: true
end

class Employee < ApplicationRecord
  has_many :pictures, as: :imageable
end

class Product < ApplicationRecord
  has_many :pictures, as: :imageable
end
```

```ruby
class CreatePictures < ActiveRecord::Migration[8.0]
  def change
    create_table :pictures do |t|
      t.string :name
      t.belongs_to :imageable, polymorphic: true
      t.timestamps
    end
  end
end
```

## 4.2 Models with Composite Primary Keys

- Rails can infer primary key-foreign key relationships, but when using composite primary keys, Rails defaults to the id column unless explicitly specified.

- Refer to the Composite Primary Keys guide for details on handling associations with composite keys in Rails.


## 4.3 Self Joins

- A self-join is when a table joins itself, commonly used for hierarchical relationships like employees and managers.

```ruby
class Employee < ApplicationRecord
  has_many :subordinates, class_name: "Employee", foreign_key: "manager_id"
  belongs_to :manager, class_name: "Employee", optional: true
end
```

```ruby
class CreateEmployees < ActiveRecord::Migration[8.0]
  def change
    create_table :employees do |t|
      t.belongs_to :manager, foreign_key: { to_table: :employees }
      t.timestamps
    end
  end
end
```

```bash
employee = Employee.find(1)
subordinates = employee.subordinates
manager = employee.manager
```

# 5. Single Table Inheritance (STI) in Rails

- `Single Table Inheritance (STI)` allows multiple models to be stored in a single database table. This is useful when different entities share common attributes and behavior but also have specific behaviors.

## 5.1 Generating the Base Vehicle Model

```bash
$ bin/rails generate model vehicle type:string color:string price:decimal{10.2}
```

- The type field is crucial as it differentiates between models (e.g., Car, Motorcycle, Bicycle).

## 5.2 Generating Child Models

```bash
$ bin/rails generate model car --parent=Vehicle
```

- Generates a model that inherits from Vehicle without creating a separate table.

```ruby
class Car < Vehicle
end
```

- This allows Car to use all behaviors and attributes of Vehicle.

## 5.3 Creating Records

```bash
Car.create(color: "Red", price: 10000)

# SQL Generated:

INSERT INTO "vehicles" ("type", "color", "price") VALUES ('Car', 'Red', 10000)
```

## 5.4 Querying Records

```bash
Car.all

# SQL Generated:

SELECT "vehicles".* FROM "vehicles" WHERE "vehicles"."type" IN ('Car')
```

## 5.5 Adding Specific Behavior

```ruby
class Car < Vehicle
  def honk
    "Beep Beep"
  end
end
```
```bash
car = Car.first
car.honk  # => 'Beep Beep'
```

## 5.6 Controllers

- Each model can have its own controller:

```ruby
class CarsController < ApplicationController
  def index
    @cars = Car.all
  end
end
```

## 5.7 Overriding the Inheritance Column

- If using a different column name (e.g., kind instead of type):

```ruby
class Vehicle < ApplicationRecord
  self.inheritance_column = "kind"
end
```

## 5.8 Disabling STI

- To treat type as a normal column:

```ruby
class Vehicle < ApplicationRecord
  self.inheritance_column = nil
end
```
```bash
Vehicle.create!(type: "Car")  # Treated as a normal attribute
```

# 6. Delegated Types in Rails

- Delegated types solve the Single Table Inheritance (STI) issue of table bloat by allowing shared attributes to be stored in a superclass table while subclass-specific attributes remain in separate tables.

## 6.1 Setting up Delegated Types

- A superclass stores shared attributes.

- Subclasses inherit from the superclass and have separate tables for additional attributes.

- Prevents unnecessary attribute sharing across all subclasses.

## 6.2 Generating Models

- Run the following commands to generate models:

```bash
$ bin/rails generate model entry entryable_type:string entryable_id:integer
$ bin/rails generate model message subject:string body:string
$ bin/rails generate model comment content:string
```

```ruby
class Entry < ApplicationRecord
end

class Message < ApplicationRecord
end

class Comment < ApplicationRecord
end
```

## 6.3 Declaring delegated_type

- Define `delegated_type` in the superclass:

```ruby
class Entry < ApplicationRecord
  delegated_type :entryable, types: %w[ Message Comment ], dependent: :destroy
end
```

- `entryable_type` stores the subclass name.

- `entryable_id` stores the subclass record ID.

## 6.4 Defining the Entryable Module

- Create a module to associate subclasses:

```ruby
module Entryable
  extend ActiveSupport::Concern
  
  included do
    has_one :entry, as: :entryable, touch: true
  end
end
```

- Include it in subclass models:

```ruby
class Message < ApplicationRecord
  include Entryable
end

class Comment < ApplicationRecord
  include Entryable
end
```

## 6.5 Methods Provided by Delegated Types

| Method                      | Returns                                                       |
|-----------------------------|---------------------------------------------------------------|
| `Entry.entryable_types`     | `["Message", "Comment"]`                                      |
| `Entry#entryable_class`     | `Message` or `Comment`                                        |
| `Entry#entryable_name`      | `"message"` or `"comment"`                                    |
| `Entry.messages`            | `Entry.where(entryable_type: "Message")`                      |
| `Entry.comments`            | `Entry.where(entryable_type: "Comment")`                      |
| `Entry#message?`            | `true if entryable_type == "Message"`                         |
| `Entry#comment?`            | `true if entryable_type == "Comment"`                         |
| `Entry#message`             | `Message` record if `entryable_type == "Message"`, else `nil` |
| `Entry#comment`             | `Comment` record if `entryable_type == "Comment"`, else `nil` |


## 6.6 Object Creation

- Create an Entry with a subclass object:

```bash
Entry.create! entryable: Message.new(subject: "hello!")
```

## 6.7 Adding Further Delegation

- Delegate methods to subclasses:

```ruby
class Entry < ApplicationRecord
  delegated_type :entryable, types: %w[ Message Comment ]
  delegate :title, to: :entryable
end

class Message < ApplicationRecord
  include Entryable

  def title
    subject
  end
end

class Comment < ApplicationRecord
  include Entryable

  def title
    content.truncate(20)
  end
end
```

- This allows `Entry#title` to call subject for Message and a truncated content for Comment.


# 7. Tips, Tricks, and Warnings

## 7.1 Controlling Association Caching

- Active Record associations use caching to store loaded data.

```bash
author.books.load   # Loads books from DB
author.books.size   # Uses cached books
author.books.empty? # Uses cached books
```

- Use `.reload` to refresh data from the database:

```bash
author.books.reload.empty?
```

## 7.2 Avoiding Name Collisions

- Avoid naming associations using reserved `ActiveRecord::Base` methods like attributes or connection to prevent conflicts.

## 7.3 Updating the Schema

- Associations do not modify the database schema; migrations must be created manually.

### 7.3.1 Creating Foreign Keys for `belongs_to`

```ruby
class AddAuthorToBooks < ActiveRecord::Migration[8.0]
  def change
    add_reference :books, :author
  end
end
```

### 7.3.2 Creating Join Tables for `has_and_belongs_to_many`

- Default join table follows lexical ordering (e.g., authors_books).

- Example migration without a primary key:

```ruby
class CreateAssembliesPartsJoinTable < ActiveRecord::Migration[8.0]
  def change
    create_table :assemblies_parts, id: false do |t|
      t.bigint :assembly_id
      t.bigint :part_id
    end

    add_index :assemblies_parts, :assembly_id
    add_index :assemblies_parts, :part_id
  end
end
```

- Alternatively, use `create_join_table`:

```ruby
class CreateAssembliesPartsJoinTable < ActiveRecord::Migration[8.0]
  def change
    create_join_table :assemblies, :parts do |t|
      t.index :assembly_id
      t.index :part_id
    end
  end
end
```

### 7.3.3 Creating Join Tables for `has_many :through`

- Requires an `id` column.

```ruby
class CreateAppointments < ActiveRecord::Migration[8.0]
  def change
    create_table :appointments do |t|
      t.belongs_to :physician
      t.belongs_to :patient
      t.datetime :appointment_date
      t.timestamps
    end
  end
end
```

## 7.4 Controlling Association Scope

- Associations within the same module work automatically:

```ruby
module MyApplication::Business
  class Supplier < ApplicationRecord
    has_one :account
  end
  class Account < ApplicationRecord
    belongs_to :supplier
  end
end
```

- If models exist in different modules, specify `class_name` explicitly:

```ruby
module MyApplication::Business
  class Supplier < ApplicationRecord
    has_one :account, class_name: "MyApplication::Billing::Account"
  end
end
module MyApplication::Billing
  class Account < ApplicationRecord
    belongs_to :supplier, class_name: "MyApplication::Business::Supplier"
  end
end
```

## 7.5 Bi-directional Associations

- Rails detects bi-directional associations automatically:

```ruby
class Author < ApplicationRecord
  has_many :books
end
class Book < ApplicationRecord
  belongs_to :author
end
```

- **Benefits**:
  - Prevents unnecessary queries.
  - Ensures data consistency.
  - Auto-saves associated records.
  - Validates presence of associations.

### 7.5.1 Handling Custom Foreign Keys

- Active Record does **not** auto-detect bi-directional relationships when custom foreign keys are used:

```ruby
class Author < ApplicationRecord
  has_many :books
end
class Book < ApplicationRecord
  belongs_to :writer, class_name: "Author", foreign_key: "author_id"
end
```

- This may cause extra queries and inconsistent data.

- Solution: Use `inverse_of` to explicitly declare bi-directionality:

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: "writer"
end
```
