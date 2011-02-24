require 'dm-core'
require 'dm-validations'
current_path = File.dirname(__FILE__) + "/"

require "user_behavior.rb"
require "#{current_path}utils.rb"
require "#{current_path}analysis.rb"
require 'fastercsv'


`ls models`.split("\n").each {|model| require "#{current_path}/models/#{model}"}
`ls analyses`.split("\n").each {|analysis| require "#{current_path}analyses/#{analysis}"}
`ls extensions`.split("\n").each {|analysis| require "#{current_path}extensions/#{analysis}"}

DataMapper.finalize

all_my_bases = {"e" => "140kit_scratch_2", "t" => "140kit_scratch_1"}
rightful_names = {'e' => 'egypt', 't' => 'tunisia'}
