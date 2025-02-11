class CreateDocumentsSectionsAndParagraphs < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.string :title
      t.timestamps
    end

    create_table :sections do |t|
      t.string :title
      t.belongs_to :document, null: false, foreign_key: true
      t.timestamps
    end

    create_table :paragraphs do |t|
      t.text :content
      t.belongs_to :section, null: false, foreign_key: true
      t.timestamps
    end
  end
end
