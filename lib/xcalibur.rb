
def unpack(string)
	string.unpack("C*").map{|val| val if val == 9 || val == 10 || val == 13 || (val > 31 && val < 127) }
end
Sld_Row = Struct.new(:sldfile, :methodfile, :rawfile, :sequence_vial)

module Ms
	class Xcalibur
		class BinReader # returns a string
			attr_accessor :index
			def initialize(index=0)
				@index=index
			end
			def string_extractor(array, index=0)
				string = String.new; next_index = nil
				(index..index+9000).each do |item|
					curr = array[item]; next_index = item+1
					next_item = array[next_index]
					if not curr.nil? 
						string << curr.chr
					elsif next_item.nil? && string.length >= 1
						break 
					end
				end
				@index = next_index
				string.chomp
			end
		end # BinReader
		class Sld
			attr_accessor :sldrows, :sldfile
			def initialize(filename = nil)
				@sldrows = []
				raise "Wrong file type" if File.extname(filename) != ".sld"
				@sldfile = filename if filename
			end
			def parse		# Returns Sld
				data = unpack(IO.read(File.open(@sldfile, 'r')))
				starts = [];
				data.each_index{|index| starts << index if data[index] == 63 && index > 37}
				starts.each_index do |index|
					block = sld_data_block_extractor(data, starts[index])
					block.map!{|val| val if val[/\w/]}.compact!
					block.delete_at(1) if block.length == 5
					block[2] = block[2] + "\\" if not block[2][/.*\\$/]
					methodfile = block[0] + '.meth'
					rawfile = block[2] + block[1] + '.RAW'
					vial = block[3]
					@sldrows << Sld_Row.new(@sldfile, methodfile, rawfile, vial)
				end
				self
			end
			OFFSETS = {
				#:type => 11,
				:methodfile => 35+11,			# -14 if from the end of the type...
				:postprocessing => 1,
				:filename_raw => 1,
				:filelocale => 1,
				:autosampler_vial => 1
			}
			def sld_data_block_extractor(array, location_of_question_mark)
				extr = Ms::Xcalibur::BinReader.new(location_of_question_mark)
				OFFSETS.values.map {|offset| extr.string_extractor(array, extr.index+offset) }
			end
		end # Sld
		class Method
			attr_accessor :tunefile
			def initialize(filename = nil)
				if filename
					raise "Wrong file type" if File.extname(filename) != '.meth'
					@filename = filename 
				end
			end
			def parse
				data = unpack(File.open(@filename, 'rb') {|io| io.read})
				@tunefile = BinReader.new.string_extractor(data, 12728)
				if @tunefile[/^[A-Z]:.*/] != @tunefile and File.extname(@tunefile) != ".LTQTune"
					@tunefile = BinReader.new.string_extractor(data, 12872)
				end
			end
		end # Method
	end # Xcalibur
end # Ms
