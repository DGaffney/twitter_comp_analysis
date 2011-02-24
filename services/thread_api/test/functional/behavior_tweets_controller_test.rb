require 'test_helper'

class BehaviorTweetsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:behavior_tweets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create behavior_tweet" do
    assert_difference('BehaviorTweet.count') do
      post :create, :behavior_tweet => { }
    end

    assert_redirected_to behavior_tweet_path(assigns(:behavior_tweet))
  end

  test "should show behavior_tweet" do
    get :show, :id => behavior_tweets(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => behavior_tweets(:one).to_param
    assert_response :success
  end

  test "should update behavior_tweet" do
    put :update, :id => behavior_tweets(:one).to_param, :behavior_tweet => { }
    assert_redirected_to behavior_tweet_path(assigns(:behavior_tweet))
  end

  test "should destroy behavior_tweet" do
    assert_difference('BehaviorTweet.count', -1) do
      delete :destroy, :id => behavior_tweets(:one).to_param
    end

    assert_redirected_to behavior_tweets_path
  end
end
