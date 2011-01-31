#Measure Organizations effect on data

class Analysis::OrgEffect < Analysis
   def initialize
      DataMapper.finalize
      DataMapper.setup(:default, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_1')
      DataMapper.setup(:tunisia, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_1')
      DataMapper.setup(:egypt, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_2')
   end

  def set_granularity(timechunk)
    granularity = case timechunk
      when 'day' then "%Y-%m-%e"
      when 'hour' then "%Y-%m-%e %H"
      when 'minute' then "%Y-%m-%e %H-%i"
    end
  end

  def generate(database, granularity)
   data = DataMapper.repository(database).adapter.select("select date_format(pubdate,'#{granularity}') as date, count(*) as count from tweets group by date_format(pubdate, '#{granularity}');");
   hashify(data)
  end

  private

  def hashify(data)
    data.map{|d| {"key" => d.date, "value" => d.count }} 
  end
end



