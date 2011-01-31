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
   data = DataMapper.repository(database).adapter.select("select date_format(pubdate,'#{granularity}') as date, count(*) as count from tweets group by date_format(pubdate, '#{granularity}');");
   self.hashify(data)
  end
  
  def self.generate_for_users(database, granularity, screen_names)
    data = DataMapper.repository(database).adapter.select("select date_format(pubdate,'#{granularity}') as date, count(*) as count from tweets group by date_format(pubdate, '#{granularity}') where author = \"#{screen_names.join("\" or author = \"")}\";");
    self.hashify(data)
  end
  
  def self.generate_results
    users = ["cnnbrk","nytimes","mashable","BreakingNews","TheOnion","TIME","BBCBreaking","TechCrunch","andersoncooper","GStephanopoulos","Newsweek","peoplemag","WSJ","HuffingtonPost","eonline","davidgregory","wired","TheEconomist","NickKristof","GMA","leolaporte","TweetSmarter","sanjayguptaCNN","NBA","Nightline"]
    Analysis::OrgEffect.initialize
    Analysis.to_csv(Analysis::OrgEffect.generate(:tunisia, Analysis::OrgEffect.set_granularity("day")), "tunisia_day_full")
    Analysis.to_csv(Analysis::OrgEffect.generate(:tunisia, Analysis::OrgEffect.set_granularity("hour")), "tunisia_hour_full")
    Analysis.to_csv(Analysis::OrgEffect.generate(:tunisia, Analysis::OrgEffect.set_granularity("minute")), "tunisia_minute_full")
    Analysis.to_csv(Analysis::OrgEffect.generate_for_users(:tunisia, Analysis::OrgEffect.set_granularity("day"), users), "tunisia_day_user")
    Analysis.to_csv(Analysis::OrgEffect.generate_for_users(:tunisia, Analysis::OrgEffect.set_granularity("hour"), users), "tunisia_hour_user")
    Analysis.to_csv(Analysis::OrgEffect.generate_for_users(:tunisia, Analysis::OrgEffect.set_granularity("minute"), users), "tunisia_minute_user")
    Analysis.to_csv(Analysis::OrgEffect.generate(:egypt, Analysis::OrgEffect.set_granularity("day")), "egypt_day_full")
    Analysis.to_csv(Analysis::OrgEffect.generate(:egypt, Analysis::OrgEffect.set_granularity("hour")), "egypt_hour_full")
    Analysis.to_csv(Analysis::OrgEffect.generate(:egypt, Analysis::OrgEffect.set_granularity("minute")), "egypt_minute_full")
    Analysis.to_csv(Analysis::OrgEffect.generate_for_users(:egypt, Analysis::OrgEffect.set_granularity("day"), users), "egypt_day_user")
    Analysis.to_csv(Analysis::OrgEffect.generate_for_users(:egypt, Analysis::OrgEffect.set_granularity("hour"), users), "egypt_hour_user")
    Analysis.to_csv(Analysis::OrgEffect.generate_for_users(:egypt, Analysis::OrgEffect.set_granularity("minute"), users), "egypt_minute_user")
  end
  private

  def self.hashify(data)
    data.map{|d| {"key" => d.date, "value" => d.count }} 
  end
end

