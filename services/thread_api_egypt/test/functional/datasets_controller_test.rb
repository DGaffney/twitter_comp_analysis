require 'test_helper'

class DatasetsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:datasets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dataset" do
    assert_difference('Dataset.count') do
      post :create, :dataset => { }
    end

    assert_redirected_to dataset_path(assigns(:dataset))
  end

  test "should show dataset" do
    get :show, :id => datasets(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => datasets(:one).to_param
    assert_response :success
  end

  test "should update dataset" do
    put :update, :id => datasets(:one).to_param, :dataset => { }
    assert_redirected_to dataset_path(assigns(:dataset))
  end

  test "should destroy dataset" do
    assert_difference('Dataset.count', -1) do
      delete :destroy, :id => datasets(:one).to_param
    end

    assert_redirected_to datasets_path
  end
end
