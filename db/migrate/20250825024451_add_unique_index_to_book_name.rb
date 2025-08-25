class AddUniqueIndexToBookName < ActiveRecord::Migration[8.0]
  def change
    add_index :books, :name, unique: true
  end
end