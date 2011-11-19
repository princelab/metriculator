# This is the function which unpacks the binary code and filters by allowed characters before the {Ms::Xcalibur::BinReader} parses out the actual strings
# @param [String] String to be filtered
# @return [Array] Array of the characters from the filtered string
def unpack(string)
	string.unpack("C*").map{|val| val if val == 9 || val == 10 || val == 13 || (val > 31 && val < 127) }
end
# This struct holds the information parsed from a row in the sequence file *.SLD
Sld_Row = Struct.new(:sldfile, :methodfile, :rawfile, :sequence_vial)

module Ms
# This is the class containing all the functions specific to the Xcalibur software package, and hence, the Thermo Scientific Instruments.
	class Xcalibur
    # This handles a Thermo specific parsing of binary data from a file
		class BinReader # returns a string
			attr_accessor :index
			def initialize(index=0)
				@index=index
			end
# This function handles the extraction of a string from the binary encoding Thermo wrote the file in.
# @param [Array, Integer] Array contains the characters to be parsed, and the Integer represents the starting location, which defaults to 0 if none is provided
# @return [String] Returns the extracted string
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
# This is the class which handles the parsing of the Sequence file, which is used to initiate Xcalibur runs
		class Sld
			attr_accessor :sldrows, :sldfile
			def initialize(filename = nil)
				@sldrows = []
				raise "Wrong file type" if File.extname(filename) != ".sld"
				@sldfile = filename if filename
			end
# This method parses the @sldfile and returns the class, where the data generated can be found from the @sldrows variable
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
# This Hash contains the distances, in terms of the indices which separate the fields from each other in the binary encoding of the SLD file.
			OFFSETS = {
				#:type => 11,
				:methodfile => 35+11,			# -14 if from the end of the type...
				:postprocessing => 1,
				:filename_raw => 1,
				:filelocale => 1,
				:autosampler_vial => 1
			}
# This fxn uses the OFFSETS to call {Ms::Xcalibur::BinReader} to parse the information out of the Sequence file.
# @param [Array, Integer] Array of filtered values from the parsed file, Integer representing the location of the beginning of each SLD row
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
# This fxn does all the parsing of the method file, filling in the tunefile location, running off of the given methodname
			# returns @tunefile
			def parse
				data = unpack(File.open(@filename, 'rb') {|io| io.read})
				@tunefile = BinReader.new.string_extractor(data, 12728)
				if @tunefile[/^[A-Z]:.*/] != @tunefile and File.extname(@tunefile) != ".LTQTune"
					@tunefile = BinReader.new.string_extractor(data, 12872)
        end
				if @tunefile[/^[A-Z]:.*/] != @tunefile and File.extname(@tunefile) != ".LTQTune"
					@tunefile = BinReader.new.string_extractor(data, 13750)
				end
				@tunefile
			end
		end # Method
	end # Xcalibur
end # Ms
