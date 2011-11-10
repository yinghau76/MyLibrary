require 'amazon/search'

class UnknownBookInfo

  def initialize(controller, book)
    @controller = controller
    @book = book
  end

  def image_url_small
    '/images/unknown-small.png'
  end

  def image_url_medium
    nil
  end

  def image_url_large
    nil
  end

  def url
    @controller.url_for :action => 'show', :id => @book
  end

  def isbn
    @book.isbn
  end

  def product_name
    @book.title
  end

  def authors
    nil
  end

  def release_date
    nil
  end

  def product_description
    nil
  end

end

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  DEVELOPER_ID = '0YHGRFKCTMME7GF5NQG2'

  def get_book_info(book)
    unless book.isbn.nil?
      begin
        req = Amazon::Search::Request.new(DEVELOPER_ID)
        asin = book.isbn.gsub(/-/, '')
        res = req.asin_search(asin)
        res.products.each do |product|
          return product
        end
      rescue
        logger.error("Unable to find book of ISBN:#{asin}")
      end
    end
    UnknownBookInfo.new(self, book)
  end

  def search_books_by_title(title)
    begin
      title = title.gsub(/&/, '')
      req = Amazon::Search::Request.new(DEVELOPER_ID)
      res = req.power_search("title: #{title}")
      return res.products
    rescue
      logger.error("Unable to find book by title: '#{title}'")
    end
    []
  end

  def search_books_by_asin(asin)
    begin
      req = Amazon::Search::Request.new(DEVELOPER_ID)
      res = req.asin_search(asin)
      return res.products
    rescue
      logger.error("Unable to find book by asin: '#{asin}'")
    end
    []
  end
  
  def self.add_book_by_isbn(isbn)
    req = Amazon::Search::Request.new(DEVELOPER_ID)
    asin = isbn.gsub(/-/, '')
    res = req.asin_search(asin)
    book = Book.new
    book.title = res.products[0].product_name
    book.isbn = res.products[0].isbn
    book.comment = ''
    book.save
    return book
  end

end
