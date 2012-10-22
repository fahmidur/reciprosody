class CorporaController < ApplicationController
	before_filter :auth, :except => :index
	
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
		@langs = ['English', 'Mandarin', 'Spanish', 'Hindi', 'Arabic', 'Portuguese', 'Bengali', 'Russian', 'Japanese', 'Punjabi', 'German', 'Javanese', 'Wu', 'Indonesian', 'Telugu', 'Vietnamese', 'Korean', 'French', 'Marathi', 'Tamil', 'Urdu', 'Turkish', 'Italian', 'Cantonese', 'Thai', 'Gujarati', 'Jin', 'Min', 'Persian', 'Polish', 'Pashto', 'Kannada', 'Xiang', 'Malayalam', 'Sundanese', 'Hausa', 'Oriya', 'Burmese', 'Hakka', 'Ukrainian', 'Bhojpuri', 'Tagalog', 'Yoruba', 'Maithili', 'Uzbek', 'Sindhi', 'Amharic', 'Fula', 'Romanian', 'Oromo', 'Igbo', 'Azerbaijani', 'Awadhi', 'Gan', 'Cebuano', 'Dutch', 'Kurdish', 'Serbo', 'Malagasy', 'Saraiki', 'Nepali', 'Sinhalese', 'Chittagonian', 'Zhuang', 'Khmer', 'Turkmen', 'Assamese', 'Madurese', 'Somali', 'Marwari', 'Magahi', 'Haryanvi', 'Hungarian', 'Chhattisgarhi', 'Greek', 'Chewa', 'Deccan', 'Akan', 'Kazakh', 'Min', 'Sylheti', 'Zulu', 'Czech', 'Kinyarwanda', 'Dhundhari', 'Haitian', 'Min', 'Ilokano', 'Quechua', 'Kirundi', 'Swedish', 'Hmong', 'Shona', 'Uyghur', 'Hiligaynon', 'Mossi', 'Xhosa', 'Belarusian', 'Balochi', 'Konkani'];
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
		@filename = params[:file]
		
		@langs = ['English', 'Mandarin', 'Spanish', 'Hindi', 'Arabic', 'Portuguese', 'Bengali', 'Russian', 'Japanese', 'Punjabi', 'German', 'Javanese', 'Wu', 'Indonesian', 'Telugu', 'Vietnamese', 'Korean', 'French', 'Marathi', 'Tamil', 'Urdu', 'Turkish', 'Italian', 'Cantonese', 'Thai', 'Gujarati', 'Jin', 'Min', 'Persian', 'Polish', 'Pashto', 'Kannada', 'Xiang', 'Malayalam', 'Sundanese', 'Hausa', 'Oriya', 'Burmese', 'Hakka', 'Ukrainian', 'Bhojpuri', 'Tagalog', 'Yoruba', 'Maithili', 'Uzbek', 'Sindhi', 'Amharic', 'Fula', 'Romanian', 'Oromo', 'Igbo', 'Azerbaijani', 'Awadhi', 'Gan', 'Cebuano', 'Dutch', 'Kurdish', 'Serbo', 'Malagasy', 'Saraiki', 'Nepali', 'Sinhalese', 'Chittagonian', 'Zhuang', 'Khmer', 'Turkmen', 'Assamese', 'Madurese', 'Somali', 'Marwari', 'Magahi', 'Haryanvi', 'Hungarian', 'Chhattisgarhi', 'Greek', 'Chewa', 'Deccan', 'Akan', 'Kazakh', 'Min', 'Sylheti', 'Zulu', 'Czech', 'Kinyarwanda', 'Dhundhari', 'Haitian', 'Min', 'Ilokano', 'Quechua', 'Kirundi', 'Swedish', 'Hmong', 'Shona', 'Uyghur', 'Hiligaynon', 'Mossi', 'Xhosa', 'Belarusian', 'Balochi', 'Konkani'];
				
    respond_to do |format|
      if @corpus.save
        format.html { redirect_to @corpus, notice: 'Corpus was successfully created.' }
        format.json { render json: @corpus, status: :created, location: @corpus }
      else
        format.html { render action: "new" }
        format.json { render json: @corpus.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /corpora/1
  # PUT /corpora/1.json
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
  
  def auth
  	if !user_signed_in?
  		redirect_to '/perm'
  	end
  end
end
