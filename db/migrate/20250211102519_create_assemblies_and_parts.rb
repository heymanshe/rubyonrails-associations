class CreateAssembliesAndParts < ActiveRecord::Migration[8.0]
  def change
    # Assemblies Table
    create_table :assemblies do |t|
      t.string :name
      t.timestamps
    end

    # Parts Table
    create_table :parts do |t|
      t.string :part_number
      t.timestamps
    end

    # Join Table (No primary key)
    create_table :assemblies_parts, id: false do |t|
      t.belongs_to :assembly, null: false, foreign_key: true
      t.belongs_to :part, null: false, foreign_key: true
    end
  end
end
