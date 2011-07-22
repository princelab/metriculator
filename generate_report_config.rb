tmp = File.readlines('tmp.txt')
i = tmp.size
category = nil
subcat = nil
properties = []
hash = Hash.new {|h,k| h[k] = [] } 
while i > 0
  line = tmp[i]
  i -= 1
  if line.nil?
    next
  elsif line[/belongs_to/]
    category = line[/belongs_to :(\w*)/,1]
    properties = []
  elsif line[/class/]
    subcat = line[/class (\w*)/,1]
    hash[category] << {subcat => properties}
  elsif line[/property/]
    properties << "#{line[/:(\w*)/,1]}: false"
  end
end
require 'yaml'
puts hash.to_yaml




