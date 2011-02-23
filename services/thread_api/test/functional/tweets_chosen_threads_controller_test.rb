require 'test_helper'

class TweetsChosenThreadsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tweets_chosen_threads)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tweets_chosen_thread" do
    assert_difference('TweetsChosenThread.count') do
      post :create, :tweets_chosen_thread => { }
    end

    assert_redirected_to tweets_chosen_thread_path(assigns(:tweets_chosen_thread))
  end

  test "should show tweets_chosen_thread" do
    get :show, :id => tweets_chosen_threads(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => tweets_chosen_threads(:one).to_param
    assert_response :success
  end

  test "should update tweets_chosen_thread" do
    put :update, :id => tweets_chosen_threads(:one).to_param, :tweets_chosen_thread => { }
    assert_redirected_to tweets_chosen_thread_path(assigns(:tweets_chosen_thread))
  end

  test "should destroy tweets_chosen_thread" do
    assert_difference('TweetsChosenThread.count', -1) do
      delete :destroy, :id => tweets_chosen_threads(:one).to_param
    end

    assert_redirected_to tweets_chosen_threads_path
  end
end
