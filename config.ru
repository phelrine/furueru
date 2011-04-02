$:.unshift(File.dirname(__FILE__))
	
require 'sinatra/base'
require 'app'

run FurueruApp
