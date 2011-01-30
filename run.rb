require 'rubygems'
require 'dm-core'
`ls models`.split("\n").each {|model| require "models/#{model}"}
require 'utils.rb'
require 'analysis.rb'
require 'new_de_gilader.rb'
`ls analyses`.split("\n").each {|analysis| require "analyses/#{analysis}"}
`ls extensions`.split("\n").each {|analysis| require "extensions/#{analysis}"}
