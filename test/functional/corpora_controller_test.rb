require 'test_helper'

class CorporaControllerTest < ActionController::TestCase
  setup do
    @user = users(:syed)
    @corpus = corpora(:one)
    @corpus.create_dirs

    sign_in @user
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:corpora)
  end

  test "should get new corpus page" do
    get :new
    assert_response :success
  end

  test "should create corpus" do
    assert_difference('Corpus.count') do
      post :create, corpus: { 
        description: @corpus.description, 
        language: @corpus.language, 
        name: @corpus.name, minutes: 5, 
        owner: "#{@user.name}<#{@user.email}>", 
        :num_speakers => 1
      }
    end
    assert_response :success
    response = JSON.parse(@response.body)
    assert_equal response['ok'], true
  end

  test "should NOT create corpus" do
    assert_no_difference('Corpus.count') do
      post :create, corpus: { 
        description: @corpus.description, 
        language: @corpus.language, 
        name: @corpus.name, minutes: 5, 
        owner: "#{@user.name}<#{@user.email}>", 
        :num_speakers => 0
      }
    end
    assert_response :success
    response = JSON.parse(@response.body)
    assert_equal response['ok'], false
  end

  test "should show corpus" do
    get :show, id: @corpus
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @corpus
    assert_response :success
  end

  test "should update corpus" do
    put :update, id: @corpus, corpus: { 
      description: @corpus.description, 
      language: @corpus.language, 
      name: @corpus.name, minutes: 5,
      :num_speakers => 99
    }
    assert_response :success
    response = JSON.parse(@response.body)
    assert_equal response['ok'], true
  end

  test "should NOT update corpus" do
    put :update, id: @corpus, corpus: { 
      description: @corpus.description, 
      language: @corpus.language, 
      name: @corpus.name, minutes: 5,
      :num_speakers => 0
    }
    assert_response :success
    response = JSON.parse(@response.body)
    assert_equal response['ok'], false
  end

  test "should destroy corpus" do
    assert_difference('Corpus.count', -1) do
      delete :destroy, id: @corpus
    end
    assert_redirected_to corpora_path
  end

end
