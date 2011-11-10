require "rubygems"
require_gem "activerecord"
require 'app/models/book'
require 'app/models/document'
require 'FileUtils'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :host => "localhost",
  :database => "db\\development.sqlite3")

$docs = Document.find(:all)
$docs.each do |doc|
  duplicates = $docs.select {|f| f.path == doc.path}
  duplicates.shift
  # Destroy all other duplicate import
  duplicates.each do |dup|
    puts "- Destroy duplicate #{doc.path}"
    dup.destroy
  end

  # Remove unexisting docs
  unless File.exist?(doc.path)
    puts "- Destroy missing #{doc.path}"
    doc.destroy
  end
end

Document.find(:all).each do |doc|
  if doc.path =~ /d:\\ebooks\\/i
    doc.path.sub!(/d:\\ebooks\\/i, "L:\\ebooks\\")
    doc.save
    puts "! move to #{doc.path}"
  end
end

Book.find(:all).each do |book|
  if book.isbn.length < 10
    book.isbn = ('0' * (10 - book.isbn.length)) + book.isbn
    book.save
    puts "! correct ISBN for #{book.title}"
  end

  # remove duplicate file
  book.documents.each do |doc|
    unless File.exist?(doc.path)
      puts "! clean-up #{doc.path}"
      doc.destroy
    end
    if book.documents.size == 1
      puts "* '#{book.title}' renaming document..."
      doc.rename_by_title
    end
  end
end