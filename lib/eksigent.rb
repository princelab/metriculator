
# Struct that provides the necessary organization of datapoints for graphing Eksigent hplc datafiles.
PressureTraceDataPoint = Struct.new(:time, :signal, :reference, :qa, :qb, :aux, :pa, :pb, :pc, :pd, :powera, :powerb) do
  def initialize(*args)
	  super(*args.map(&:to_f))
	end
end


module Ms
# this is the class which contains methods specific to Eksigent Products
	class Eksigent
# this is the class which contains methods specific to the Ultra2D UPLC system
		class Ultra2D
			attr_accessor :rawfile, :eksfile, :graphfile, :autosampler_vial, :inj_vol, :rawtime, :datapoints
			def initialize(rawfile = nil)
				if rawfile
					@rawfile = rawfile
					find_match
				end
			end
# This will take the metadata associated with the RAW file and determine which eksigent pressure trace file corresponds to that MsRun.
# @param None, assumes access to @rawfile
# @return [Object] self.
			def find_match
				raise "Wrong file type" if File.extname(@rawfile) != ".RAW"
				@rawtime = File.mtime(@rawfile); rawdir = File.dirname(@rawfile)
				eks_folder = "#{@rawtime.year}#{"%02d" % @rawtime.mon}#{"%02d" % @rawtime.day}"
				eks_dir = "C:\\Program Files\\Eksigent NanoLC\\autosave\\#{eks_folder}\\"
				times = Dir.entries(eks_dir).map do |each_file|
					next if File.extname(each_file) != '.txt'
					next if not File.basename(each_file)[/^ek2.*/]
					[(File.mtime("#{File.join(eks_dir.split(/[\/\\]/), each_file.split(/[\/\\]/.split(/[\/\\]/)))}")-@rawtime).abs, each_file] #[Time diff, file name] 
				end
				@eksfile = File.expand_path("#{eks_dir}/#{times.compact!.sort!.first.last}")
				raise "Match error: #{@eksfile}" if @eksfile[/^.*\/ek2_.*\.txt/] != @eksfile
				self
			end
# This parses the eksigent hplc file and creates the @data hash containing the values found
			def parse
				hash_out = {}; data_block = []
				file = File.open(@eksfile, 'r:iso-8859-1')
				file_test, sample_test, autosampler_test, data_test = false, false, false, false
				file.each_line do |line|
		# Test for which data block I am in...
					file_test = true if line == "[FILE]\r\n"
					sample_test = true and file_test = false if line == "[SAMPLE]\r\n"
					autosampler_test = true and sample_test = false if line =="[AUTOSAMPLER]\r\n"
					data_test = true and autosampler_test = false if line == "[DATA]\r\n"
		# Parse rules according to which line I am in
					@hplcfile = hash_out['hplcfile'] = line[/^Filename: (.*)\r$/,1] if not line[/^Filename: (.*$)/,1].nil? if file_test
					hash_out['inj_vol'] = line[/^Sample Injection Volume \(nL\): (\d*).*$/,1] if not line[/^Sample Injection Volume.*(\d*).*/,1].nil? if sample_test
					hash_out['vial_position'] = line[/^Autosampler Position: (\w*).*$/,1] if not line[/^Autosampler Position: (\w*).*$/,1].nil? if autosampler_test
					data_block << line if data_test
				end
				file.close()
				hash_out['plotraw'] = data_block.values_at(1..data_block.length).compact
				@data = hash_out # file_name, inj_vol, vial_position, data()
				@inj_vol = @data['inj_vol'].to_f/1000
				@autosampler_vial = @data['vial_position']
			end
# This will take the @data (or parse if not found) and generate an array of datapoints which contain the information desired as {PressureTraceDataPoint} structs, stored as @datapoints
			def structs
				parse if @data.nil?
				@data['plotraw'].shift
				@datapoints = []
				@data['plotraw'].each do |line|
					datums = line.split("\t") if not line.nil?
					datums[-1] = datums.last[/(.*)\r\n/,1]
					@datapoints << PressureTraceDataPoint.new(*datums)
				end
				@datapoints.size
			end
# This will graph the @datapoints and return the filename of the graphfile produced.  
			def graph
				structs if @datapoints.nil?
				@graphfile =  File.absolute_path(File.expand_path(@rawfile).chomp(File.extname(@rawfile)) + '.pdf')
				require 'rserve/simpler'
				output = Rserve::Simpler.new
				datafr = Rserve::DataFrame.from_structs(@datapoints)
# 	Struct.new(:time, :signal, :reference, :qa, :qb, :aux, :pa, :pb, :pc, :pd, :powera, :powerb)
				File.open('/home/ryanmt/eksigent_datafr.yml', 'w') {|out| YAML::dump(datafr, out) }
				captured = output.converse( eks_trace: datafr )  do 
					%Q{pdf(file="#{@graphfile}", height=8, width=10)
					par(mar=c(3,4,3,4)+0.1)
					attach(eks_trace)
				  plot(pc~time, axes=FALSE, type='l', ylim=range(qa,qb,pc), xlab='', ylab='')	
					axis(side=2, at = pretty(range(pc)),las=1)
					mtext("Column Pressure (psi)", side=2, line=3)
					box()
					par(new=TRUE)
					plot(qa~time, axes=FALSE, type='l', ylim=c(0,max(qa)), xlab='', ylab='', bty="n", col='blue' )
					axis(side=4, at = pretty(c(0,max(qa))),las=1)
					mtext("Gradient Flowrate (nL/min)", side=4, line=3)
					par(new=TRUE)
					plot(qb~time, axes=FALSE, type='l', ylim=c(0,max(qb)), xlab='', ylab='', col='red')
					legend('left', legend=c("Pc", 'Flowrate of Solvent A', "Flowrate of Solvent B"), text.col=c('black', 'blue', 'red'),pch=c(16,16,16),col=c('black', 'blue', 'red'))
					dev.off()
					}
				end
				@graphfile
			end #graph
		end # Ultra2d
	end # Eksigent
end # Ms
				
