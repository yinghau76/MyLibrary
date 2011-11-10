class AddComment < ActiveRecord::Migration
  def self.up
    add_column :books, :comment, :text
  end

  def self.down
    remove_column :books, :comment
  end
end
