#!/usr/bin/env ruby 

require 'rubygems'
require 'sinatra'
require 'haml'
require 'archiver'

#require 'rest'

#rest Metric

enable :sessions

before '/admin/*' do 
	authenticate!
end

get '/' do 
	haml :index
end
post '/index' do 
	name = params[:name]
	mail = params[:mail]
	body = params[:body]

	haml :index
end

get'/index/:filter1/:filter2' do |new, old|
	
end

get '/about' do
	haml :about
end

get '/home' do 
	haml :home
end

get '/chromatography' do 
	haml :chromatography
end

get '/dynamic_sampling' do 
	haml :dynamic_sampling
end

get '/ion_source' do 
	haml :ion_source
end

get '/ion_treatment' do 
	haml :ion_treatment
end

get '/ms1' do 
	haml :ms1
end

get '/ms2' do 
	haml :ms2
end

get '/peptide_id' do 
	haml :peptide_id
end

get '/run_comparison' do 
	haml :run_comparison
end

get '/database' do 
	@msruns = Msrun.all
	@metrics = Metric.all
	haml :database_overview
end


=begin
	session["counter"] ||= 0 
	session['counter'] += 1
	"Welcome to the page!\n It is so exciting!"
	#"I know you know, because you've returned #{session['counter']} times!" if session['counter'] > 1
end

get '/msruns' do 
	haml :"msruns/index"
end

=end
helpers do 
	def link_to(url, text=url, opts={})
		attributes = ""
		opts.each {|key, value| attributes << key.to_s << "=\"" << value << "\" "}
		"<a href=\"#{url}\" #{attributes}>#{text}</a>"
	end
	def list_link(url, text=url, opts={})
		attributes = ''
		opts.each {|key, value| attributes << key.to_s << "=\"" << value << "\" "}
		"<a href=\"#{url}\" #{attributes}> <li #{text}</li> </a>"
	end
	def img(locale)
		"<img src='#{locale}' alt='#{locale.slice(/.*\/(\w*)\.svg/,1)}' />"
	end
end
