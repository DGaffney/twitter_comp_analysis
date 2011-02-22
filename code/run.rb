current_path = File.dirname(__FILE__) + "/"
require 'rubygems'
require 'dm-core'
`ls models`.split("\n").each {|model| require "#{current_path}/models/#{model}"}
require "#{current_path}utils.rb"
require "#{current_path}analysis.rb"
require "#{current_path}new_de_gilader.rb"
`ls analyses`.split("\n").each {|analysis| require "#{current_path}analyses/#{analysis}"}
`ls extensions`.split("\n").each {|analysis| require "#{current_path}extensions/#{analysis}"}
Analysis::OrgEffect.generate_results