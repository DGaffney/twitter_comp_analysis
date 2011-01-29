require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'dm-aggregates'
require 'models/user'

DataMapper.finalize
DataMapper.setup(:default, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/ian_140kit')

require 'utils'
require 'em-http'
require 'json'