#!/usr/bin/env ruby
# Ruby Hash class, gotta love meta-programming!
class Hash
  # This function provides a deep merge feature for hashes, which will handle any level of hash depth, merging hashes and replacings Strings and combining Arrays
# @param [Hash] Hash to merge into the self Hash
# @return [Hash] Hash which contains the merge of the source hashes
	def deep_merge(hash2)
		out_hash = {}
		keys = self.keys | hash2.keys # Is this wrong?  OR?  SHouldn't I use a combination of them?
		keys.each do |k|
			v = self[k]
		#	puts "k: #{k}\nv: #{v}\t and v2: #{hash2[k]}"
			if v.is_a?(Hash) and hash2[k].is_a?(Hash)
				out_hash[k] = self[k].deep_merge(hash2[k])
		#		puts "outhash[k] looks like: #{out_hash[k]}"
			elsif v.nil?
        out_hash[k] = hash2[k]
      else
				out_hash[k] = v
				next if v == hash2[k]
				if v.class == Array 
					out_hash[k] = hash2[k] if v.empty?
          out_hash[k] = hash2[k] if v.length < hash2[k].length
        elsif v.class == String
          out_hash[k] = hash2[k] if v.empty?
				end
		#		puts "outhash[k] looks like: #{out_hash[k]}"
			end
		end
		out_hash
	end
end
