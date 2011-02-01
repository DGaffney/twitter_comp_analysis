#Measure Organizations effect on data

class Analysis::OrgEffect < Analysis
  def self.initialize
    DataMapper.finalize
    DataMapper.setup(:default, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_1')
    DataMapper.setup(:tunisia, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_1')
    DataMapper.setup(:egypt, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_2')
  end

  def self.set_granularity(timechunk)
    granularity = case timechunk
      when 'day' then "%Y-%m-%e"
      when 'hour' then "%Y-%m-%e %H"
      when 'minute' then "%Y-%m-%e %H-%i"
    end
  end

  def self.generate(database, granularity)
   data = DataMapper.repository(database).adapter.select("select date_format(pubdate,'#{granularity}') as date, count(*) as count from tweets group by date_format(pubdate, '#{granularity}') order by pubdate;");
   self.hashify(data)
  end
  
  def self.generate_for_users(database, granularity, screen_names)
    data = DataMapper.repository(database).adapter.select("select date_format(pubdate,'#{granularity}') as date, count(*) as count from tweets where author = '#{screen_names.join("' or author = '")}' group by date_format(pubdate, '#{granularity}') order by pubdate;")
    self.hashify(data)
  end
  
  def self.generate_results
    users = ["cnnbrk","nytimes","mashable","BreakingNews","TheOnion","TIME","BBCBreaking","TechCrunch","andersoncooper","GStephanopoulos","Newsweek","peoplemag","WSJ","HuffingtonPost","eonline","davidgregory","wired","TheEconomist","NickKristof","GMA","leolaporte","TweetSmarter","sanjayguptaCNN","NBA","Nightline"]
    Analysis::OrgEffect.initialize
    tunisia = ["tunisia_day_full","tunisia_hour_full","tunisia_minute_full","tunisia_day_user","tunisia_hour_user","tunisia_minute_user"]
    egypt = ["egypt_day_full","egypt_hour_full","egypt_minute_full","egypt_day_user","egypt_hour_user","egypt_minute_user"]
    Analysis.to_csv((t_d=Analysis::OrgEffect.generate(:tunisia, Analysis::OrgEffect.set_granularity("day"))), "tunisia_day_full.csv")
    Analysis.to_csv((t_h=Analysis::OrgEffect.generate(:tunisia, Analysis::OrgEffect.set_granularity("hour"))), "tunisia_hour_full.csv")
    Analysis.to_csv((t_m=Analysis::OrgEffect.generate(:tunisia, Analysis::OrgEffect.set_granularity("minute"))), "tunisia_minute_full.csv")
    Analysis.to_csv((t_d_u=Analysis::OrgEffect.generate_for_users(:tunisia, Analysis::OrgEffect.set_granularity("day"), users)), "tunisia_day_user.csv")
    Analysis.to_csv((t_h_u=Analysis::OrgEffect.generate_for_users(:tunisia, Analysis::OrgEffect.set_granularity("hour"), users)), "tunisia_hour_user.csv")
    Analysis.to_csv((t_m_u=Analysis::OrgEffect.generate_for_users(:tunisia, Analysis::OrgEffect.set_granularity("minute"), users)), "tunisia_minute_user.csv")
    Analysis.to_csv((e_d=Analysis::OrgEffect.generate(:egypt, Analysis::OrgEffect.set_granularity("day"))), "egypt_day_full.csv")
    Analysis.to_csv((e_h=Analysis::OrgEffect.generate(:egypt, Analysis::OrgEffect.set_granularity("hour"))), "egypt_hour_full.csv")
    Analysis.to_csv((e_m=Analysis::OrgEffect.generate(:egypt, Analysis::OrgEffect.set_granularity("minute"))), "egypt_minute_full.csv")
    Analysis.to_csv((e_d_u=Analysis::OrgEffect.generate_for_users(:egypt, Analysis::OrgEffect.set_granularity("day"), users)), "egypt_day_user.csv")
    Analysis.to_csv((e_h_u=Analysis::OrgEffect.generate_for_users(:egypt, Analysis::OrgEffect.set_granularity("hour"), users)), "egypt_hour_user.csv")
    Analysis.to_csv((e_m_u=Analysis::OrgEffect.generate_for_users(:egypt, Analysis::OrgEffect.set_granularity("minute"), users)), "egypt_minute_user.csv")
    tunisia_datasets = [t_d,t_h,t_m,t_d_u,t_h_u,t_m_u]
    egypt_datasets = [e_d,e_h,e_m,e_d_u,e_h_u,e_m_u]
    tunisia.each do |name|
      Graph.save_new_data_set(tunisia_datasets[tunisia.index(name)], name, :tunisia)
    end
    egypt.each do |name|
      Graph.save_new_data_set(egypt_datasets[egypt.index(name)], name, :egypt)
    end
  end
  
  private

  def self.hashify(data)
    data.map{|d| {"key" => d.date, "value" => d.count }} 
  end
end

