CygBin = "C:\\cygwin\\bin"
CygHome = "C:\\cygwin\\home\\LTQ2"
UserHost = 'ryanmt@jp1'
ProgramLocale = '/home/ryanmt/Dropbox/coding/ms/archiver/lib/archiver.rb'

def to_linux(object)
	File.open('tmp.yml','w'){|out|	YAML.dump(object, out) }
	file_move = %Q[#{CygBin}\\scp tmp.yml #{UserHost}:/tmp/]
	kick = %Q[#{CygBin}\\ssh #{UserHost} -C '#{ProgramLocale} --linux /tmp/tmp.yml ']
 %x[#{kick}]  #Doesn't work on linux, obviously
	kick
end
=begin 
def to_linux(object)
	File.open( 'tmp.yaml', 'w') do |out|
		YAML.dump( object, out)
	end
	file_dest = Database.cp_under_mount('tmp.yaml')
	output = %Q[#{CygBin}\\cygpath.exe -aw "#{CygHome}\\.ssh\\config].chomp
	p output

	kick = %Q[#{CygBin}\\ssh #{UserHost} -C "#{ProgramLocale} --linux ]
# %x[#{kick}]
	kick
end
=end
