module Ms
  class ComparisonGrapher
    class << self
      # Takdes a DataMapper query and turns the matches into the same data structure as is produced by parsing the data file.
      # @param [Array] An array containing the matches to the DataMapper database query
      # @return [Hash] A hash of a hash of a hash, containing the data desired, but it really should be an array of out_hashes, right?
      def match_to_hash(matches)
        # matches is the result of a Msrun.all OR Msrun.first OR Msrun.get(*args)
        @data = {}
        matches.each do |msrun|
          next if msrun.metric.nil?
          index = msrun.raw_id.to_s
          @data[index] = {'timestamp' => msrun.rawtime || Time.random(1)}
          @@categories.each do |cat|
            @data[index][cat] = msrun.metric.send(cat.to_sym).hashes
            @data[index][cat].keys.each do |subcat|	
              @data[index][cat][subcat].delete('id'.to_sym)
              @data[index][cat][subcat].delete("#{cat}_id".to_sym)
            end
          end
        end
        @data # as a hash of a hash of a hash
      end

      # This fxn produces an array containing {Measurement} structs which contain the data found in all the matches produced by a DataMapper DB query
      # @param [Array] an Array of matches
      # @return [Array] an Array containing all the measurements found in the DB matches given
      def slice_matches(matches)
        measures = []
        @data = {}
        # Why is this line of code here?
        #        debugger
        matches = [matches] if !matches.is_a? DataMapper::Collection
        matches.each do |msrun|
          next if msrun.nil? or msrun.metric.nil?
          index = msrun.raw_id.to_s
          @data[index] = {'timestamp' => msrun.rawtime || Time.random(1)}
          @@categories.each do |cat|
            @data[index][cat] = msrun.metric.send(cat.to_sym).hashes
            @data[index][cat].keys.each do |subcat|	
              @data[index][cat][subcat].delete('id'.to_sym)
              @data[index][cat][subcat].delete("#{cat}_id".to_sym)
              @data[index][cat][subcat].delete("#{cat}_metric_msrun_id".to_sym)
              @data[index][cat][subcat].delete("#{cat}_metric_msrun_raw_id".to_sym)
              @data[index][cat][subcat].delete("#{cat}_metric_metric_input_file".to_sym)
              @data[index][cat][subcat].each { |property, value|
                measures << Measurement.new( property, index, @data[index]['timestamp'], value, cat.to_sym, subcat.to_sym) }
            end
          end
        end
        measures.sort
      end
# This function takes the same parameters as {#graph_matches} and accomplishes the same result, as well as generating and returning, instead of the filenames, a hash containing the information needed to do cool stuff
      # @param [Array, Array] Arrays of measurements sliced from the results of two DataMapper DB queries, the first of which represents the newest in a QC run, which will be compared to the previous values
      # @return [Hash] ### WHAT WILL IT CONTAIN?  THE VARIANCE AND THE MEAN?  OR A RANGE OF ALLOWED VALUES, or a true false value??? ##### ... I'm not yet sure, thank you very much
      def graph_and_stats(new_measure, old_measures)
        default_variance = QcConfig[:default_allowed_variance]
        require 'rserve/simpler'
        graphfiles = []
        measures = [new_measure, old_measures]
        data_hash = {}
        r_object = Rserve::Simpler.new
        r_object.converse('library("beanplot")')
        @@categories.map do |cat|
          data_hash[cat.to_sym] = {}
          subcats = measures.first.map{|meas| meas.subcat if meas.category == cat.to_sym}.compact.uniq
          Dir.mkdir(cat) if !Dir.exist?(cat)
          subcats.each do |subcategory|
            data_hash[cat.to_sym][subcategory] = {}
            graphfile_prefix = File.join([Dir.pwd, cat, (subcategory.to_s)])
            Dir.mkdir(graphfile_prefix) if !Dir.exist?(graphfile_prefix)
            # Without removing the file RAWID from the name:
            #graphfile_prefix = File.join([Dir.pwd, cat, (rawid + '_' + subcategory.to_s)])
            new_structs = measures.first.map{|meas| meas if meas.subcat == subcategory.to_sym}.compact
            old_structs = measures.last.map{|meas| meas if meas.subcat == subcategory.to_sym}.compact

            [new_structs, old_structs].each do |structs|
              structs.each do |str|
                str.value = str.value.to_f
                str.name = str.name.to_s
                str.category = str.category.to_s
                str.subcat = str.subcat.to_s
                str.time = str.time.to_s.gsub(/T/, ' ').gsub(/-(\d*):00/,' \100')
              end
            end
            datafr_new = Rserve::DataFrame.from_structs(new_structs)
            datafr_old = Rserve::DataFrame.from_structs(old_structs)
            r_object.converse( df_new: datafr_new )	do
              %Q{df_new$time <- strptime(as.character(df_new$time), "%Y-%m-%d %X")
                    df_new$name <- factor(df_new$name)
                    df_new$category <-factor(df_new$category)
                    df_new$subcat <- factor(df_new$subcat)
                    df_new$raw_id <- factor(df_new$raw_id)
              }
            end # new datafr converse
            r_object.converse( df_old: datafr_old) do
              %Q{df_old$time <- strptime(as.character(df_old$time), "%Y-%m-%d %X")
                  df_old$name <- factor(df_old$name)
                  df_old$category <-factor(df_old$category)
                  df_old$subcat <- factor(df_old$subcat)
                  df_old$raw_id <- factor(df_old$raw_id)
              }
            end # old datafr converse
            count = new_structs.map {|str| str.name }.uniq.compact.length
            i = 1;
            names = r_object.converse("levels(df_old$name)")
            while i <= count
              r_object.converse do
                %Q{	df_new.#{i} <- subset(df_new, name == levels(df_new$name)[[#{i}]])
                    df_old.#{i} <- subset(df_old, name == levels(df_old$name)[[#{i}]])			

                    old_time_plot <- data.frame(df_old.#{i}$time, df_old.#{i}$value)
                    new_time_plot <- data.frame(df_new.#{i}$time, df_new.#{i}$value)
                }
              end
            # Configure the environment for the graphing, by setting up the numbered categories
              curr_name = r_object.converse("levels(df_old$name)[[#{i}]]")
## THIS IS WHERE WE DO THE CALCULATIONS
              if not QcConfig[cat.to_sym][subcategory.to_s.split('_').map{|word| word.capitalize}.join("").to_sym].nil?
                t = QcConfig[cat.to_sym][subcategory.to_s.split('_').map{|word| word.capitalize}.join("").to_sym][curr_name]
                variance = t.is_a?(Numeric) ? t : default_variance
                mean = r_object.converse("mean(df_old.#{i}$value)")
                sd = r_object.converse("sd(df_old.#{i}$value)")
                data_hash[cat.to_sym][subcategory][curr_name] = [mean, sd] 
                new_point = r_object.converse("df_new.#{i}$value")
                range = mean-variance*sd..mean+variance*sd
                Alerter.create("#{cat.to_sym}--#{subcategory}--#{curr_name} has exceeded range: #{range} Mean #{mean} Variance #{variance} Standard deviation #{sd} Value #{new_point}") if not ( range === new_point or range.member?(new_point) )
              end
## END
              graphfile = File.join([graphfile_prefix, curr_name + '.svg'])
              graphfiles << graphfile
              r_object.converse(%Q{svg(file="#{graphfile}", bg="transparent", height=3, width=7.5)})
              r_object.converse('par(mar=c(1,1,1,1), oma=c(2,1,1,1))')
              r_object.converse do
                %Q{	tmp <- layout(matrix(c(1,2),1,2,byrow=T), widths=c(3,4), heights=c(1,1))
                      tmp <- layout(matrix(c(1,2),1,2,byrow=T), widths=c(3,4), heights=c(1,1))		}
              end
              r_object.converse do
                %Q{	band1 <- try(bw.SJ(df_old.#{i}$value), silent=TRUE)
                      if(inherits(band1, 'try-error')) band1 <- try(bw.nrd0(df_old.#{i}$value), silent=TRUE)		}
              end
              r_object.converse( "ylim = range(density(c(df_old.#{i}$value, df_new.#{i}$value), bw=band1)[[1]])")
              r_object.converse do
                %Q{	beanplot(df_old.#{i}$value, df_new.#{i}$value,  side='both', log="", names=df_old$name[[#{i}]], col=list('sandybrown',c('skyblue3', 'black')), innerborder='black', bw=band1)
                    plot(old_time_plot, type='l', lwd=2.5, ylim = ylim, col='sandybrown', pch=15)
                    if (length(df_new.#{i}$value) > 5) {
                      lines(new_time_plot,type='l',ylab=df_new.#{i}$name[[1]], col='skyblue3', pch=16, lwd=3 )
                    } else {
                      points(new_time_plot,ylab=df_new.#{i}$name[[1]], col='skyblue4', bg='skyblue3', pch=21, cex=1.2)
                    }
                    dev.off()
                }
              end
              i +=1
            end # while loop
          end # subcats
        end	# categories
       # graphfiles
# TODO Do I send the email here?
       data_hash
      end


      # This function generates a comparison between the two sets of data, which are sliced by {#slice_matches}, graphing the results as SVG files.
      # @param [Array, Array] Arrays of measurements sliced from the results of two DataMapper DB queries
      # @return [Array] An array which contains all of the files produced by the process.  This will likely be an array of approximately 400 filenames.
      def graph_matches(new_measures, old_measures)
        require 'rserve/simpler'
        graphfiles = []
        measures = [new_measures, old_measures]
        r_object = Rserve::Simpler.new
        r_object.converse('library("beanplot")')
        @@categories.map do |cat|
          subcats = measures.first.map{|meas| meas.subcat if meas.category == cat.to_sym}.compact.uniq
          Dir.mkdir(cat) if !Dir.exist?(cat)
          subcats.each do |subcategory|
            graphfile_prefix = File.join([Dir.pwd, cat, (subcategory.to_s)])
            Dir.mkdir(graphfile_prefix) if !Dir.exist?(graphfile_prefix)
            # Without removing the file RAWID from the name:
            #graphfile_prefix = File.join([Dir.pwd, cat, (rawid + '_' + subcategory.to_s)])
            new_structs = measures.first.map{|meas| meas if meas.subcat == subcategory.to_sym}.compact
            old_structs = measures.last.map{|meas| meas if meas.subcat == subcategory.to_sym}.compact
            [new_structs, old_structs].each do |structs|
              structs.each do |str|
                str.value = str.value.to_f
                str.name = str.name.to_s
                str.category = str.category.to_s
                str.subcat = str.subcat.to_s
                str.time = str.time.to_s.gsub(/T/, ' ').gsub(/-(\d*):00/,' \100')
              end
            end
            datafr_new = Rserve::DataFrame.from_structs(new_structs)
            datafr_old = Rserve::DataFrame.from_structs(old_structs)
            r_object.converse( df_new: datafr_new )	do
              %Q{df_new$time <- strptime(as.character(df_new$time), "%Y-%m-%d %X")
                    df_new$name <- factor(df_new$name)
                    df_new$category <-factor(df_new$category)
                    df_new$subcat <- factor(df_new$subcat)
                    df_new$raw_id <- factor(df_new$raw_id)
              }
            end # new datafr converse
            r_object.converse( df_old: datafr_old) do
              %Q{df_old$time <- strptime(as.character(df_old$time), "%Y-%m-%d %X")
                  df_old$name <- factor(df_old$name)
                  df_old$category <-factor(df_old$category)
                  df_old$subcat <- factor(df_old$subcat)
                  df_old$raw_id <- factor(df_old$raw_id)
              }
            end # old datafr converse
            count = new_structs.map {|str| str.name }.uniq.compact.length
            i = 1;
            while i <= count
              r_object.converse do
                %Q{	df_new.#{i} <- subset(df_new, name == levels(df_new$name)[[#{i}]])
                    df_old.#{i} <- subset(df_old, name == levels(df_old$name)[[#{i}]])			

                    old_time_plot <- data.frame(df_old.#{i}$time, df_old.#{i}$value)
                    new_time_plot <- data.frame(df_new.#{i}$time, df_new.#{i}$value)
                }
              end
            # Configure the environment for the graphing, by setting up the numbered categories
              names = r_object.converse("levels(df_old$name)")
              curr_name = r_object.converse("levels(df_old$name)[[#{i}]]")
              graphfile = File.join([graphfile_prefix, curr_name + '.svg'])
              graphfiles << graphfile
              r_object.converse(%Q{svg(file="#{graphfile}", bg="transparent", height=3, width=7.5)})
              r_object.converse('par(mar=c(1,1,1,1), oma=c(2,1,1,1))')
              r_object.converse do
                %Q{	tmp <- layout(matrix(c(1,2),1,2,byrow=T), widths=c(3,4), heights=c(1,1))
                      tmp <- layout(matrix(c(1,2),1,2,byrow=T), widths=c(3,4), heights=c(1,1))		}
              end
              r_object.converse do
                %Q{	band1 <- try(bw.SJ(df_old.#{i}$value), silent=TRUE)
                      if(inherits(band1, 'try-error')) band1 <- try(bw.nrd0(df_old.#{i}$value), silent=TRUE)		}
              end
              r_object.converse( "ylim = range(density(c(df_old.#{i}$value, df_new.#{i}$value), bw=band1)[[1]])")
              r_object.converse do
                %Q{	beanplot(df_old.#{i}$value, df_new.#{i}$value,  side='both', log="", names=df_old$name[[#{i}]], col=list('sandybrown',c('skyblue3', 'black')), innerborder='black', bw=band1)
                    plot(old_time_plot, type='l', lwd=2.5, ylim = ylim, col='sandybrown', pch=15)
                    if (length(df_new.#{i}$value) > 5) {
                      lines(new_time_plot,type='l',ylab=df_new.#{i}$name[[1]], col='skyblue3', pch=16, lwd=3 )
                    } else {
                      points(new_time_plot,ylab=df_new.#{i}$name[[1]], col='skyblue4', bg='skyblue3', pch=21, cex=1.2)
                    }
                    dev.off()
                }
              end
              i +=1
            end # while loop
          end # subcats
        end	# categories
        graphfiles
      end # graph_files

      @@categories = ["chromatography", "ms1", "dynamic_sampling", "ion_source", "ion_treatment", "peptide_ids", "ms2", "run_comparison"]
      def stats_to_database

      end #stats_to_database
    end #class << self
  end #ComparisonGrapher
end #module Ms
