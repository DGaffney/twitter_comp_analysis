require 'test_helper'

class ChosenThreadsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:chosen_threads)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create chosen_thread" do
    assert_difference('ChosenThread.count') do
      post :create, :chosen_thread => { }
    end

    assert_redirected_to chosen_thread_path(assigns(:chosen_thread))
  end

  test "should show chosen_thread" do
    get :show, :id => chosen_threads(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => chosen_threads(:one).to_param
    assert_response :success
  end

  test "should update chosen_thread" do
    put :update, :id => chosen_threads(:one).to_param, :chosen_thread => { }
    assert_redirected_to chosen_thread_path(assigns(:chosen_thread))
  end

  test "should destroy chosen_thread" do
    assert_difference('ChosenThread.count', -1) do
      delete :destroy, :id => chosen_threads(:one).to_param
    end

    assert_redirected_to chosen_threads_path
  end
end
