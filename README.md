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

## 8. Disabling STI

- To treat type as a normal column:

```ruby
class Vehicle < ApplicationRecord
  self.inheritance_column = nil
end
```
```bash
Vehicle.create!(type: "Car")  # Treated as a normal attribute
```
 