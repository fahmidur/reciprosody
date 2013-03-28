require 'test_helper'


class CorpusTest < ActiveSupport::TestCase
  test "empty corpus should not save" do
  	corpus = Corpus.new
  	assert !corpus.save
  end

  test "completed corpus should save" do
  	corpus = Corpus.new
  	corpus.language = "English"
  	corpus.num_speakers = 1
  	corpus.hours = 1
  	corpus.name = "Test Name For Corpus"
  	assert corpus.save
  end

  test "corpus specifically without NAME should not save" do
  	corpus = Corpus.new
  	
  	# Set everything else
  	corpus.language = "English"
  	corpus.num_speakers = 1
  	corpus.hours = 1

  	# Verify that this corpus has no name
  	assert !corpus.name
  	assert !corpus.save
  end

  
  test "corpus specifically without LANGUAGE should not save" do
  	corpus = Corpus.new
  	
  	# Set everything else
  	corpus.name = "Test Name For Corpus"
  	corpus.num_speakers = 1
  	corpus.hours = 1

  	# Verify that this corpus has no LANGUAGE
  	assert !corpus.language
  	assert !corpus.save
  end

  test "corpus specifically without NUM_SPEAKERS should save" do
  	corpus = Corpus.new
  	
  	# Set everything else
  	corpus.name = "Test Name For Corpus"
  	corpus.language = "English"
  	corpus.hours = 1

  	# Verify that this corpus has no NUM_SPEAKERS
  	assert !corpus.num_speakers
  	assert !corpus.save
  end

  test "corpus specifically with Zero NUM_SPEAKERS should save" do
  	corpus = Corpus.new
  	
  	# Set everything else
  	corpus.name = "Test Name For Corpus"
  	corpus.language = "English"
  	corpus.hours = 1

  	corpus.num_speakers = 0

  	# Verify that this corpus has no NUM_SPEAKERS
  	assert corpus.num_speakers == 0
  	assert !corpus.save
  end

  test "corpus specifically with Negative NUM_SPEAKERS should save" do
  	corpus = Corpus.new
  	
  	# Set everything else
  	corpus.name = "Test Name For Corpus"
  	corpus.language = "English"
  	corpus.hours = 1

  	corpus.num_speakers = -5

  	# Verify that this corpus has no NUM_SPEAKERS
  	assert corpus.num_speakers < 0
  	assert !corpus.save
  end

  test "corpus with Zero HOURS, MINUTES, and SECONDS should not save" do
  	corpus = Corpus.new
  	corpus.name = "Test Name For Corpus"
  	corpus.language = "English"
  	corpus.num_speakers = 1

  	corpus.hours = 0
  	corpus.minutes = 0
  	corpus.seconds = 0

  	assert corpus.hours == 0 && corpus.minutes == 0 && corpus.seconds == 0
  	assert !corpus.save
  end

  test "corpus with Negative HOURS, MINUTES, and SECONDS should not save" do
  	corpus = Corpus.new
  	corpus.name = "Test Name For Corpus"
  	corpus.language = "English"
  	corpus.num_speakers = 1

  	corpus.hours = -5
  	corpus.minutes = -5
  	corpus.seconds = -5

  	assert corpus.hours < 0 && corpus.minutes < 0 && corpus.seconds < 0
  	assert !corpus.save
  end


end
