# Gems
require "rubygems"
require "bundler/setup"
require "sinatra"
require "haml"
require 'sinatra/form_helpers'
require "pry"
require "curb"
require 'json'
require "redis"
require "net/http"

configure do
	set :run, false
	set :raise_errors, true
	set :haml, format: :html5 

	##################################
	# ENV needed
	##################################

	# ENV["REDISTOGO_URL"] = " " # Redis credentials
	# ENV["AUTH"] = " " # spark cloud auth
	# ENV["DEVISE_ID"] = " " # spark core devise id
	# ENV["DEVISE_NAME"] = " " # devise name for redis 
end

require "./app"

run App