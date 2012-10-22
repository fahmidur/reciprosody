require 'test_helper'

class CorporaControllerTest < ActionController::TestCase
  setup do
    @corpus = corpora(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:corpora)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create corpus" do
    assert_difference('Corpus.count') do
      post :create, corpus: { description: @corpus.description, language: @corpus.language, name: @corpus.name }
    end

    assert_redirected_to corpus_path(assigns(:corpus))
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
    put :update, id: @corpus, corpus: { description: @corpus.description, language: @corpus.language, name: @corpus.name }
    assert_redirected_to corpus_path(assigns(:corpus))
  end

  test "should destroy corpus" do
    assert_difference('Corpus.count', -1) do
      delete :destroy, id: @corpus
    end

    assert_redirected_to corpora_path
  end
end
