class AdminController < ApplicationController

  PER_PAGE = 20
  BOOK_ORDER = "id"

  before_filter :authorize
  before_filter :check_admin, :only => [:new, :edit, :update, :destroy, :purge, :rename, :edit_doc, :delete_doc, :ajax_destroy_doc, :ajax_purge_doc, :ajax_book_update]
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  #verify :method => :post, :only => [ :destroy, :create, :update ],
  #       :redirect_to => { :action => :list }

  # This method will use params[:query] and params[:query] to prepare data
  def list
    @query = params[:query]
    @pages = []
    @books = []
    if params[:page] || @query
      case @query
      when /type:(\w+)/
        case $1
        when /^unavail/i
          @books = Book.find_unavailable_books
          @pages = Paginator.new(self, @books.length, PER_PAGE, params[:page])
        when /^dup/i
          @books = Book.find_dup_books
          @pages = Paginator.new(self, @books.length, PER_PAGE, params[:page])
        end
        page = (params[:page] ||= 1).to_i
        offset = (page - 1) * PER_PAGE
        @books = @books[offset..(offset + PER_PAGE - 1)]          
      when /tag:(\w+)/
        tag = $1
        @pages, @books = paginate(
          :books,
          :conditions => "tags like '%#{tag}%'",
          :order => BOOK_ORDER,
          :per_page => PER_PAGE)
      else
        @pages, @books = paginate(
          :books,
          :conditions => "title LIKE '%#{@query}%'",
          :order => BOOK_ORDER,
          :per_page => PER_PAGE)
      end
    end
  end

  def show
    @book = Book.find(params[:id])
    params[:query] ||= @book.title_query_string
  end

  def new
    if request.post?
      # check whether there is already one with the same ISBN.
      @book = Book.find_by_isbn(params[:book][:isbn])
      if @book
        @book.update_attributes(params[:book])
      else
        @book = Book.new(params[:book])
      end

      # add document to this book
      if params[:document]
        @book.documents << Document.find(params[:document])
      end

      if @book.save
        flash[:notice] = 'Book was successfully created.'
        redirect_to :action => 'show', :id => @book
      end
    else
      @book = Book.new
    end
  end

  def edit
    @book = Book.find(params[:id])
  end

  def update
    @book = Book.find(params[:id])
    if @book.update_attributes(params[:book])
      flash[:notice] = 'Book was successfully updated.'
      redirect_to :action => 'show', :id => @book
    else
      render :action => 'edit'
    end
  end

  def destroy
    if Book.find(params[:id]).destroy
      flash[:notice] = 'Book was successfully destroyed.'
    else
      flash[:notice] = 'Failed to destroy book.'
    end
    redirect_to :action => 'list'
  end

  def purge
    begin
      book = Book.find(params[:id])
      book.documents.each do |doc|
        File.delete(doc.path)
      end
    rescue Exception => e
      flash[:notice] = e.message
    end
    destroy
  end

  def download
    doc = Document.find(params[:id])
    send_file(doc.path, :type => doc.content_type, :disposition => 'inline')
  end

  def rename
    @book = Book.find(params[:id])
    begin
      @book.documents.each {|doc| doc.rename_by_title}
    rescue Exception => e
      flash[:notice] = e.message
      logger.error(e.message)
    end
    redirect_to :action => 'show', :id => @book
  end

  def ajax_amazon_search
    if book_id = params[:book_id]
      @book = Book.find(book_id)
    elsif doc_id = params[:doc_id]
      @doc = Document.find(doc_id)
    end
  end

  # called when user select a Amazon book to update info from
  def ajax_book_update
    @book = Book.find(params[:id])
    @book.isbn = params[:isbn]
    @book.title = params[:title]
    @book.save
  end

  def ajax_switch_page
    # call list to prepare data for current page
    list
  end

  def ajax_book_search
    # call list to prepare data for current page
    list
  end

  # params: :query and :page will be used
  def list_doc
    @query = params[:query]
    @pages = []
    @docs = []
    if request.post? || @query
      case @query
      when /type:(\w+)/
        case $1
        when /^unknown/i
          @docs = Document.find_unknown
          @pages = Paginator.new(self, @docs.length, PER_PAGE, params[:page])
          
          page = (params[:page] ||= 1).to_i
          offset = (page - 1) * PER_PAGE
          @docs = @docs[offset..(offset + PER_PAGE - 1)]
        end
      else
        @pages, @docs = paginate(
          :documents,
          :conditions => "path LIKE '%#{@query}%'",
          :per_page => PER_PAGE)
      end
    end
  end

  def ajax_purge_doc
    begin
      doc = Document.find(params[:doc])
      File.delete(doc.path)
      doc.destroy
    rescue Exception => e
      flash[:notice] = e.message
    end
    @book = Book.find(params[:id])

    render :action => 'ajax_book_update'
  end

  def ajax_destroy_doc
    doc = Document.find(params[:doc])
    doc.destroy
    @book = Book.find(params[:id])

    render :action => 'ajax_book_update'
  end

  def ajax_switch_doc_page
    list_doc
  end

  def edit_doc
    @doc = Document.find(params[:id])
    if request.post?
      if @doc.update_attributes(params[:doc])
        flash[:notice] = 'Document was successfully updated.'
      else
        flash[:notice] = 'Document was not updated because of some error.'
      end
    end
  end

  def delete_doc
    @doc = Document.find(params[:id])
    @book = @doc.book
    begin
      flash[:notice] = "#{@doc.path} was deleted."
      File.delete(@doc.path)
    rescue Exception => e
      flash[:notice] = "Error happened: #{e.message}"
    ensure
      @doc.destroy
    end
    if @book.nil?
      redirect_to :action => :index
    else
      redirect_to :action => :show, :id => @book
    end
  end

end
