csvs = [["participants_per_thread","select thread_id,count(distinct(author)) from tweets_chosen_threads group by thread_id order by count(distinct(author)) desc;"],
["posts_per_date_per_thread","select date(pubdate),count(id),thread_id from tweets_chosen_threads group by thread_id,date(pubdate) order by thread_id;"],
["posts_per_thread","select thread_id,count(id) from tweets_chosen_threads group by thread_id order by count(id) desc;"],
["posts_per_actor_type","select profiles.p_type,tweets_chosen_threads.thread_id,count(tweets_chosen_threads.id) from tweets_chosen_threads inner join profiles on profiles.p_screen_name=tweets_chosen_threads.author group by tweets_chosen_threads.thread_id,profiles.p_type"],
["actor_type_breakdown","select p_type,count(p_id) from profiles group by p_type;"],
["average_followers_per_actor","select p_type,avg(p_followers_count) from profiles group by p_type;"],
["average_friends_per_actor","select p_type,avg(p_following_count) from profiles group by p_type;"],
["average_followers_per_actor_per_thread"," select profiles.p_type,avg(profiles.p_follower_count),tweets_chosen_threads.thread_id from profiles inner join tweets_chosen_threads on tweets_chosen_threads.author=profiles.p_screen_name group by profiles.p_type,tweets_chosen_threads.thread_id order by tweets_chosen_threads.thread_id;"],
["average_friends_per_actor_per_thread","select profiles.p_type,avg(profiles.p_following_count),tweets_chosen_threads.thread_id from profiles inner join tweets_chosen_threads on tweets_chosen_threads.author=profiles.p_screen_name group by profiles.p_type,tweets_chosen_threads.thread_id order by tweets_chosen_threads.thread_id;"]]

load "new_de_gilader.rb"
load "analysis.rb"

module CSVPump
  def self.pump_them_csvs(csv_sets)
    csv_sets.each do |name, query|
      dataset = DataMapper.repository(:default).adapter.select(query)
      Analysis.to_csv(dataset, name, )
    end
  end
  
end