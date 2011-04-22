require 'spec_helper'

describe 'References images correctly' do
	before do 
		@imageblock = Image.new( {location: '/home/ryanmt/Dropbox/coding/ms/archiver/chromatography/first_and_last_ms1_rt_min_first_ms1.svg'} )
	end
	it 'has appropriate html for the location' do 
		@imageblock.to_html.should.equal "<img alt=\"chromatography/first_and_last_ms1_rt_min_first_ms1.svg\" src=\"/home/ryanmt/Dropbox/coding/ms/archiver/chromatography/first_and_last_ms1_rt_min_first_ms1.svg\" />"
	end
end

describe 'Generates HTML' do 
	it 'makes an index page' do 
		@h = Home.new
		@h.to_html(:pretty_print => true).should.equal 'hi'
	end
end
