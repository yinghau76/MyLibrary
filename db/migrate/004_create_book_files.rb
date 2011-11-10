class CreateBookFiles < ActiveRecord::Migration
  def self.up
    create_table :book_files do |t|
      t.column :book_id, :integer
      t.column :path, :string
      t.column :format, :string
    end
  end

  def self.down
    drop_table :book_files
  end
end
