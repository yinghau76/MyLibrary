class Document < ActiveRecord::Base
  belongs_to :book

  def path=(p)
    write_attribute(:path, p.downcase.gsub(/\//, '\\'))
  end

  def size
    begin
      File.stat(path).size
    rescue
      return 0
    end
  end

  def self.find_unknown
    find(:all, :conditions => "book_id is NULL")
  end

  CONTENT_TYPE = {
    '.pdf' => 'application/pdf',
    '.ppt' => 'application/vnd',
    '.doc' => 'application/msword',
    '.zip' => 'application/zip',
  }

  def content_type
    CONTENT_TYPE[File.extname(path)] || 'application/octet-stream'
  end

  def filename
    Pathname.new(path).basename.to_s
  end

  def rename_by_title
    old_doc = Pathname.new(path)
    new_doc = Pathname.new(book.format_local_filename(old_doc.extname))
    new_doc = old_doc.dirname.join(new_doc).to_s.gsub(/\//, "\\")
    old_doc = old_doc.to_s.gsub(/\//, "\\")
    if old_doc.casecmp(new_doc) != 0
      FileUtils.cp path, new_doc
      FileUtils.rm path
      #logger.info "old name: '#{path}'"
      self.path = new_doc
      #logger.info "new name: '#{path}'"
      save
    end
  rescue
    #log.info "Unable to rename #{path}"
  end

  FILE_ICON = {
    '.pdf' => 'pdf.gif',
    '.chm' => 'chm.gif',
    '.rar' => 'rar.gif',
    '.zip' => 'rar.gif',
  }
    
  def file_icon
    FILE_ICON[File.extname(path)] || 'unknown-medium.png'
  end

end
