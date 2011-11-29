#########################333333 RANDOM TIME GENERATOR!!!

class Time
# This function provides me a way to set a reasonable historical window for generating fake dates in spec cases.
	def self.random(years_back=1)
		year = Time.now.year - rand(years_back) - 1
		month = rand(12) + 1
		day = rand(31) + 1 
		hour = rand(23) + 1
		minute = rand(59) + 1
		Time.local(year, month, day, hour, minute)
	end
end
