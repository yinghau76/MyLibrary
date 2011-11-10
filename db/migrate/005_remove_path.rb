
class RemovePath < ActiveRecord::Migration
  def self.up
    books = Book.find(:all)
    books.each do |book|
      file = BookFile.new
      file.path = book.path
      file.book_id = book.id
      file.save
    end
    remove_column :books, :path
  end

  def self.down
    add_column :books, :path
    files = BookFile.find(:all)
    files.each do |file|
      unless file.book.nil?
        file.book.path = file.path
        file.destroy
      end
    end
  end
end
