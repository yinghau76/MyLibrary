class AddBookType < ActiveRecord::Migration
  def self.up
    remove_column :books, :md5
    add_column :books, :tags, :string
  end

  def self.down
    add_column :books, :md5, :string
    remove_column :books, :tags
  end
end
