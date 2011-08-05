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
      y = hash2[k]
			puts "k: #{k}\nv: #{v}\t and value: #{y}"
			if v == y
        out_hash[k] = y
      elsif y.nil?
        out_hash[k] = v
      elsif v.nil?
        out_hash[k] = y
      elsif v.is_a?(Hash) and y.is_a?(Hash)
				out_hash[k] = v.deep_merge(y)
				puts "outhash[#{k}] looks like: #{out_hash[k]}"
			elsif v.class == Array
        if y.empty? or y.length < v.length
          out_hash[k] = v
        else
          out_hash[k] = y
        end
      elsif v.class == String
        out_hash[k] = y unless y.empty?
        out_hash[k] ||= v
      elsif v.class == TrueClass or FalseClass
        out_hash[k] = y
      else
        out_hash[k] = v
			end
      puts "outhash[#{k}] looks like: #{out_hash[k]}"
		end
    puts "outhash looks like: #{out_hash}"
		out_hash
	end
end
