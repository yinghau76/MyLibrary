require "digest/md5"

class Book < ActiveRecord::Base

  validates_presence_of :title
  validates_presence_of :isbn
  has_many :documents

  DEFAULT_BOOK_ORDER = "id"

  def title_query_string
    title.gsub(/[_:]/, ' ')
  end

  def format_local_filename(ext)
    title.gsub(/[:\/\\]/, '-') + " [#{isbn}]#{ext}"
  end

  def self.find_isbn_duplicates
    find_by_sql ["select * from books where isbn = ? and id <> ?", isbn, id]
  end

  def self.find_by_isbn(isbn)
    find(:first, :conditions => "isbn = '#{isbn}'")
  end

  def self.find_by_title(title)
    find(:all, :conditions => "title LIKE '%#{title}%'")
  end

  def self.find_by_tag(tag)
    find(:all, :conditions => "tags like '%#{tag}%'")
  end

  def self.find_dup_books
    find(:all, :order => DEFAULT_BOOK_ORDER).select {|book| !book.find_isbn_duplicates.empty?}
  end

  def self.find_unavailable_books
    find(:all, :order => DEFAULT_BOOK_ORDER).select {|book| book.documents.empty?}
  end

  def isbn=(isbn)
    write_attribute(:isbn, isbn.gsub(/-/, ''))
  end

  protected
  def validate
  end

end
