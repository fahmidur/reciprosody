class CorporaController < ApplicationController
	before_filter :auth, :except => :index
	autocomplete :language, :name
	autocomplete :license, :name
	
  # GET /corpora
  # GET /corpora.json
  def index
    @corpora = Corpus.all
		
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @corpora }
    end
  end

  # GET /corpora/1
  # GET /corpora/1.json
  def show
    @corpus = Corpus.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @corpus }
    end
  end

  # GET /corpora/new
  # GET /corpora/new.json
  def new
    @corpus = Corpus.new
		
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @corpus }
    end
  end

  # GET /corpora/1/edit
  def edit
    @corpus = Corpus.find(params[:id])
  end

  # POST /corpora
  def create
    @corpus = Corpus.new(params[:corpus])
		@file = @corpus.upload_file
		
		logger.info "FILE = #{@file}"
		
		

		@corpus.valid? #note to self, overwrites existing errors
		if !@file
  		@corpus.errors[:upload_file] = " is missing"
		end
		
	  respond_to do |format|
	    if @corpus.errors.none? && create_corpus() && @corpus.save
	      format.html { redirect_to @corpus, notice: 'Corpus was successfully created.' }
	    else
	      format.html { render action: "new" }
	    end
	  end
	
  end

  # PUT /corpora/1
  def update
    @corpus = Corpus.find(params[:id])

    respond_to do |format|
    	if @corpus.update_attributes(params[:corpus])
        format.html { redirect_to @corpus, notice: 'Corpus was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @corpus.errors, status: :unprocessable_entity }
      end
    end
    

  end

  # DELETE /corpora/1
  # DELETE /corpora/1.json
  def destroy
    @corpus = Corpus.find(params[:id])
    @corpus.destroy

    respond_to do |format|
      format.html { redirect_to corpora_url }
      format.json { head :no_content }
    end
  end
  
  private
  
  def create_corpus
  	archive_ext = get_archive_ext(@file.original_filename);
  	if !archive_ext
  		@corpus.errors[:file_type] = "must be zip or tar.gz or tgz"
  		return false
  	end
  	
  	#prepare xtract directory
  	@corpus.utoken = gen_unique_token()
  	
  	logger.info "----utoken = #{@corpus.utoken}"
  	
  	xtract_dir = "corpora.files/#{@corpus.utoken}"
  	Dir.mkdir xtract_dir unless Dir.exists? xtract_dir
  	
  	#prepare archive directory
  	archive_dir = "corpora.archives/#{@corpus.utoken}"
  	
  	
  	Dir.mkdir archive_dir unless Dir.exists? archive_dir
  	archive_path = "#{archive_dir}/#{file_count(archive_dir)}.#{archive_ext}"
  	logger.info "-----------------PATH = #{archive_path}"
  	logger.info "-----------------FILETYPE = #{@file.class}"
  	File.open(archive_path, "wb") {|f| f.write(@file.read)}
  	
  	return true
  end
  
  
  def gen_unique_token()
  	utoken = ""
  	begin
  		utoken = SecureRandom.uuid
  	end while Corpus.where(:utoken => utoken).exists?
  	return utoken
  end
  
  def get_archive_ext(string)
  	return "tar.gz" if string =~ /\.tar\.gz$/
  	return "tgz" if string =~ /\.tgz$/
  	return "zip" if string =~ /\.zip$/
  	return nil
  end
  
  def file_count(dir)
  	return Dir.glob("#{dir}/*").length
  end
  
  def auth
  	if !user_signed_in?
  		redirect_to '/perm'
  	end
  end
end
