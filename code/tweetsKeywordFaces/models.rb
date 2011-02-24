require 'rubygems'
require 'dm-core'

DataMapper.setup(:default, 'mysql://user:pass@localhost/egypt')

class Tweet
  include DataMapper::Resource
  property :id,             Serial
  property :screen_name,    String
  property :followers,      Integer, :default => 0 
  property :tweet,          Text
  property :profile_image,  Text  
  property :created_at,     DateTime
end

DataMapper.finalize
