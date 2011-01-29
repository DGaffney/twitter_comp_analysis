require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'dm-aggregates'
require 'models/user'

DataMapper.finalize
DataMapper.setup(:default, 'mysql://username:password@hostname.com/database')

require 'utils'
require 'em-http'
require 'json'