class CreateBooks < ActiveRecord::Migration
  def self.up
    create_table :books do |t|
      t.column :title, :string
      t.column :isbn, :string
      t.column :path, :string
      t.column :md5, :string
    end
  end

  def self.down
    drop_table :books
  end
end
