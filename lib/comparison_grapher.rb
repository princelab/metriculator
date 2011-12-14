# These are the values which are defaults for the Alerter settings in {ComparisonGrapher#graph_and_stats} function
Graphing_defaults = {email_alert: true}
module Ms
# This is the class which handles the responses from DB queries and generates comparison graphs
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
        measures = []; @data = {}
        # Why is this line of code here?
        # debugger
        matches = [matches] if !matches.is_a? DataMapper::Collection and !matches.is_a? Array
        matches.each do |msrun|
          next if msrun.nil? or msrun.metric.nil?
          index = msrun.raw_id.to_s
          @data[index] = {'timestamp' => msrun.rawtime || Time.random(1)}
          @@categories.each do |cat|
            if cat == "uplc"
              arr = [{"hplc_max_p" => msrun.hplc_max_p || 0}, {'hplc_avg_p' => msrun.hplc_avg_p || 0}, {'hplc_std_p' => msrun.hplc_std_p || 0}]
              arr.each do |prop|
                measures << Measurement.new(prop.keys.first, index, @data[index]['timestamp'], prop[prop.keys.first], cat.to_sym, :pressure_trace)
              end
            else
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
        end
        measures.sort_by {|measure| measure.category}
      end
# This function takes the same parameters as {#graph_matches} and accomplishes the same result, as well as generating and returning, instead of the filenames, a hash containing the information needed to do cool stuff
      # @param [Array, Array] Arrays of measurements sliced from the results of two DataMapper DB queries, the first of which represents the newest in a QC run, which will be compared to the previous values
      # @return [Hash] ### WHAT WILL IT CONTAIN?  THE VARIANCE AND THE MEAN?  OR A RANGE OF ALLOWED VALUES, or a true false value??? ##### ... I'm not yet sure, thank you very much
     def graph_and_stats(old_measures, new_measure, comparison_folder, opts = {})
        options = Graphing_defaults.merge(opts)
        default_variance = QcConfig[:default_allowed_variance]
        require 'rserve/simpler'
        FileUtils.mkdir_p(comparison_folder)
        graphfiles = []
        measures = [new_measure, old_measures]
        data_hash = {}
        r_object = Rserve::Simpler.new
        r_object.converse('library("beanplot")')
        r_object.converse "setwd('#{Dir.pwd}')"
        @@categories.map do |cat|
          data_hash[cat.to_sym] = {}
          subcats = measures.first.map{|meas| meas.subcat if meas.category == cat.to_sym}.compact.uniq
          subcats.each do |subcategory|
            data_hash[cat.to_sym][subcategory] = {}
            graphfile_prefix = File.join(comparison_folder, cat, subcategory.to_s)
            FileUtils.mkdir_p(graphfile_prefix)
            new_structs = measures.first.map{|meas| meas if meas.subcat == subcategory.to_sym}.compact
            old_structs = measures.last.map{|meas| meas if meas.subcat == subcategory.to_sym}.compact
            [new_structs, old_structs].each do |structs|
              structs.each do |str|
                str.value = str.value.to_f
                str.name = str.name.to_s
                str.category = @@name_legend[str.category.to_s]
                str.subcat = @@name_legend[str.subcat.to_s]
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
                    old_time_plot <- old_time_plot[order(df_old.#{i}$time), ]
                    new_time_plot <- new_time_plot[order(df_new.#{i}$time), ]
                }
              end
            # Configure the environment for the graphing, by setting up the numbered categories

              curr_name = r_object.converse("levels(df_old$name)[[#{i}]]")
## THIS IS WHERE WE DO THE CALCULATIONS
              if not QcConfig[cat.to_sym][subcategory.to_s.split('_').map{|word| word.capitalize}.join("").to_sym].nil?
                t = QcConfig[cat.to_sym][subcategory.to_s.split('_').map{|word| word.capitalize}.join("").to_sym][curr_name]
                variance = t.is_a?(Numeric) ? t : default_variance
                mean = r_object.converse("mean(df_old.#{i}$value)")
                sd = r_object.converse("try(sd(df_old.#{i}$value), silent=TRUE)")
                data_hash[cat.to_sym][subcategory][curr_name] = [mean, sd] 
                new_point = r_object.converse("df_new.#{i}$value")
                range = mean-variance*sd..mean+variance*sd
                Alerter.create("#{cat.to_sym}--#{subcategory}--#{curr_name} has exceeded range: #{range} Mean #{mean} Variance #{variance} Standard deviation #{sd} Value #{new_point}", { :email => options[:email_alert] }) if not ( range === new_point or range.member?(new_point) )
              end
## END
              graphfile = File.join([graphfile_prefix, curr_name + '.svg'])
              graphfiles << graphfile
              name = @@name_legend[curr_name]
              r_object.converse(%Q{svg(file="#{graphfile}", bg="transparent", height=3, width=7.5)})
              r_object.converse('par(mar=c(1,1,1,1), oma=c(2,1,1,1))')
              r_object.converse do
                %Q{	tmp <- layout(matrix(c(1,2),1,2,byrow=T), widths=c(3,4), heights=c(1,1))
                    tmp <- layout(matrix(c(1,2),1,2,byrow=T), widths=c(3,4), heights=c(1,1))		}
              end
              r_object.converse %Q{	band1 <- try(bw.SJ(df_old.#{i}$value), silent=TRUE)
                      if(inherits(band1, 'try-error')) band1 <- try(bw.nrd0(df_old.#{i}$value), silent=TRUE)		
                      if(inherits(band1, 'try-error')) band1 <- try(bw.nrd0(df_new.#{i}$value), silent=TRUE)		
                      if(inherits(band1, 'try-error')) band1 <- 0.99   }
              r_object.converse "ylim = range(density(c(df_old.#{i}$value, df_new.#{i}$value), bw=band1)[[1]])"
              t_test = r_object.converse ("try(t.test(df_old.#{i}$value, df_new.#{i}$value), silent=TRUE)")
              case t_test
                when String
                  t_test_out = "ERR: Data are constant"
                when Float
                  t_test_out = "%.2g" % t_test
              end
              r_object.converse %Q{ xlim = range(old_time_plot$df_old.#{i}.time, new_time_plot$df_new.#{i}.time) }
              r_object.converse %Q{ beanplot(df_old.#{i}$value, df_new.#{i}$value, side='both', log="", names="p-value:#{t_test_out}", col=list('deepskyblue4',c('firebrick', 'black')), innerborder='black', bw=band1)}  
              r_object.converse do
                %Q{ plot(old_time_plot, type='l', lwd=2.5, xlim = xlim, ylim = ylim, col='deepskyblue4', pch=15)
                    if (length(df_new.#{i}$value) > 4) {
                      lines(new_time_plot,type='l',ylab=df_new.#{i}$name[[1]], col='firebrick', pch=16, lwd=3 )
                    } else {
                      points(new_time_plot,ylab=df_new.#{i}$name[[1]], col='skyblue4', bg='firebrick', pch=21, cex=1.2)
                    }
                    title <- "#{@@name_legend[cat]}--#{@@name_legend[subcategory.to_s]}--#{name}"
                    if (nchar(title) > 80) {
                      mtext(title, side=3, line=0, outer=TRUE, cex=0.7)
                    } else if (nchar(title) > 100 ) {
                      mtext(title, side=3, line=0, outer=TRUE, cex=0.6)
                    } else if (nchar(title) > 120 ) {
                      mtext(title, side=3, line=0, outer=TRUE, cex=0.5)
                    } else {
                      mtext(title, side=3, line=0, outer=TRUE)
                    }
                }
              end
              r_object.converse "dev.off()" # This line must end the loop, to prevent R from crashing.
              i +=1
            end # while loop
          end # subcats
        end	# categories
       # graphfiles
# TODO Do I send the email here?
       data_hash
      end # graph_and_stats

      # This function generates a comparison between the two sets of data, which are sliced by {#slice_matches}, graphing the results as SVG files.
      # @param [Array, Array] Arrays of measurements sliced from the results of two DataMapper DB queries
      # @return [Array] An array which contains all of the files produced by the process.  This will likely be an array of approximately 400 filenames.
      def graph_matches(old_measures, new_measures, comparison_folder, opts = {})
        options = Graphing_defaults.merge(opts)
        require 'rserve/simpler'
        FileUtils.mkdir_p(comparison_folder)
        graphfiles = []
        measures = [new_measures, old_measures]
        #$DEBUG = true
        r_object = Rserve::Simpler.new
        r_object.converse('library("beanplot")')
        r_object.converse "setwd('#{Dir.pwd}')"
        #r_object.converse('library("Cairo")')
        @@categories.map do |cat|
          subcats = measures.first.map{|meas| meas.subcat if meas.category == cat.to_sym}.compact.uniq
          #p Dir.exist?(File.join(AppConfig[:comparison_directory], comparison_folder.to_s, cat))
          #p subcats
          subcats.each do |subcategory|
            graphfile_prefix = File.join(comparison_folder, cat, subcategory.to_s)
            FileUtils.mkdir_p(graphfile_prefix) 
            #p Dir.exist?(graphfile_prefix)
            new_structs = measures.first.map{|meas| meas if meas.subcat == subcategory.to_sym}.compact
            old_structs = measures.last.map{|meas| meas if meas.subcat == subcategory.to_sym}.compact
            [new_structs, old_structs].each do |structs|
              structs.each do |str|
                str.value = str.value.to_f
                str.name = str.name.to_s
                str.category = @@name_legend[str.category.to_s]
                str.subcat = @@name_legend[str.subcat.to_s]
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
                    old_time_plot <- old_time_plot[order(df_old.#{i}$time), ]
                    new_time_plot <- new_time_plot[order(df_new.#{i}$time), ]
                }
              end
#              p r_object.converse "summary(df_old.#{i})" if $DEBUG
#              p r_object.converse "summary(df_new.#{i})" if $DEBUG
            # Configure the environment for the graphing, by setting up the numbered categories
              curr_name = r_object.converse("levels(df_old$name)[[#{i}]]")
              graphfile = File.join([graphfile_prefix, curr_name + ".svg"])
              graphfiles << graphfile
              name = @@name_legend[curr_name]
              r_object.converse(%Q{svg(file="#{graphfile}", bg="transparent", height=3, width=7.5)})
              r_object.converse('par(mar=c(1,1,1,1), oma=c(2,1,1,1))')
              r_object.converse do
                %Q{	tmp <- layout(matrix(c(1,2),1,2,byrow=T), widths=c(3,4), heights=c(1,1))
                    tmp <- layout(matrix(c(1,2),1,2,byrow=T), widths=c(3,4), heights=c(1,1))		}
              end
              r_object.converse %Q{	band1 <- try(bw.SJ(df_old.#{i}$value), silent=TRUE)
                      if(inherits(band1, 'try-error')) band1 <- try(bw.nrd0(df_old.#{i}$value), silent=TRUE)
                      if(inherits(band1, 'try-error')) band1 <- try(bw.nrd0(df_new.#{i}$value), silent=TRUE)		
                      if(inherits(band1, 'try-error')) band1 <- 0.99
              }
              r_object.converse "ylim = range(density(c(df_old.#{i}$value, df_new.#{i}$value), bw=band1)[[1]])"
              t_test = r_object.converse ("try(t.test(df_old.#{i}$value, df_new.#{i}$value)$p.value, silent=TRUE)")
#              p r_object.converse( "df_old.#{i}$value" ) if $DEBUG
#              p r_object.converse( "df_new.#{i}$value" ) if $DEBUG
              case t_test
                when String
                  t_test_out = "ERR: Data are constant"
                when Float
                  t_test_out = "%.2g" % t_test
              end
              r_object.converse %Q{ xlim = range(old_time_plot$df_old.#{i}.time, new_time_plot$df_new.#{i}.time) }
              r_object.converse %Q{beanplot(df_old.#{i}$value, df_new.#{i}$value, side='both', log="", names="p-value: #{t_test_out}", col=list('deepskyblue4',c('firebrick', 'black')), innerborder='black', bw=band1)} 
              r_object.converse do
# TODO!!!
                %Q{ plot(old_time_plot, type='l', lwd=2.5, xlim = xlim, ylim = ylim, col='deepskyblue4', pch=15)
                    if (length(df_new.#{i}$value) > 4) {
                      lines(new_time_plot,type='l',ylab=df_new.#{i}$name[[1]], col='firebrick', pch=16, lwd=3 )
                    } else {
                      points(new_time_plot,ylab=df_new.#{i}$name[[1]], col='skyblue4', bg='firebrick', pch=21, cex=1.2)
                    }
                    title <- "#{@@name_legend[cat]}\t#{@@name_legend[subcategory.to_s]}\t#{name}"
                    if (nchar(title) > 80) {
                      mtext(title, side=3, line=0, outer=TRUE, cex=0.75)
                    } else if (nchar(title) > 100 ) {
                      mtext(title, side=3, line=0, outer=TRUE, cex=0.65)
                    } else if (nchar(title) > 120 ) {
                      mtext(title, side=3, line=0, outer=TRUE, cex=0.55)
                    } else {
                      mtext(title, side=3, line=0, outer=TRUE)
                    }
                }
              end
              r_object.converse "dev.off()" #### This line must conclude each loop, as far as R is concerned.
              i +=1
            end # while loop
          end # subcats
        end	# categories
        graphfiles
      end # graph_files

      @@categories = ["uplc", "chromatography", "ms1", "dynamic_sampling", "ion_source", "ion_treatment", "peptide_ids", "ms2", "run_comparison"]
      @@name_legend = { "uplc"=>"UPLC","chromatography"=>"Chromatography", "ms1"=>"MS1", "ms2"=>"MS2", "dynamic_sampling"=>"Dynamic Sampling", "ion_source"=>"Ion Source", "ion_treatment"=>"Ion Treatment", "peptide_ids"=> "Peptide IDs", "run_comparison"=>"Run Comparison", "id_charge_distributions_at_different_ms1max_quartiles_for_charges_1_4"=>"ID Charge Distributions At Different MS1max Quartiles For Charges 1-4", "precursor_m_z_averages_and_differences_from_1st_quartile_largest_of_different_ms1total_tic_quartiles_over_full_elution_period"=>"Precursor m/z Averages and Differences from 1st Quartile (Largest) of Different MS1Total (TIC) Quartiles Over Full Elution Period", 
      "number_of_compounds_in_common"=>"Number of Compounds in Common", "fraction_of_overlapping_compounds_relative_to_first_index"=>"Fraction of Overlapping Compounds - relative to first index", "fraction_of_overlapping_compounds_relative_to_second_index"=>"Fraction of Overlapping Compounds - relative to second index", "median_retention_rank_differences_for_compounds_in_common_percent"=>"Median Retention Rank Differences for Compounds in Common (Percent)", "avg_1_60_1_60"=>"Avg\t1.60\t1.60", 
      "average_retention_rank_differences_for_compounds_in_common_percent"=>"Average Retention Rank Differences for Compounds in Common (Percent)", "avg_2_30_2_30"=>"Avg\t2.30\t2.30", "number_of_matching_identified_ions_between_runs"=>"Number of Matching Identified Ions Between Runs", "relative_deviations_in_ms1_max_for_matching_identified_ions_between_runs"=>"Relative Deviations in MS1 Max For Matching Identified Ions Between Runs", "avg_1_00_1_00"=>"Avg\t1.00\t1.00", "relative_uncorrected_deviations_in_ms1_max_for_matching_identified_ions_between_runs"=>"Relative Uncorrected Deviations in MS1 Max For Matching Identified Ions Between Runs", "avg_0_00_0_00"=>"Avg\t0.00\t0.00", 
      "relative_corrected_deviations_in_ms1_max_for_matching_identified_ions_between_runs"=>"Relative Corrected Deviations in MS1 Max For Matching Identified Ions Between Runs", "relative_rt_trends_in_ms1_max_for_matching_identified_ions_between_runs"=>"Relative RT Trends in MS1 Max For Matching Identified Ions Between Runs", 
      "relative_rt_trends_corrected_deviations_of_ms1_max_for_matching_identified_ions_between_runs"=>"Relative RT Trends / Corrected Deviations of MS1 Max For Matching Identified Ions Between Runs", "median_relative_intensities_in_ms1_max_for_matching_identified_ions_between_runs"=>"Median Relative Intensities in MS1 Max For Matching Identified Ions Between Runs", "number_of_matching_doubly_charged_identified_ions_between_runs"=>"Number of Matching Doubly Charged Identified Ions Between Runs", 
      "relative_deviations_in_ms1_max_for_doubly_charged_matching_identified_ions_between_runs"=>"Relative Deviations in MS1 Max For Doubly Charged Matching Identified Ions Between Runs", "number_of_matching_triply_charged_identified_ions_between_runs"=>"Number of Matching Triply Charged Identified Ions Between Runs", "relative_deviations_in_ms1_max_for_triply_charged_matching_identified_ions_between_runs"=>"Relative Deviations in MS1 Max For Triply Charged Matching Identified Ions Between Runs", 
      "relative_2_deviations_in_ms1_max_for_matching_identified_ions_between_runs"=>"Relative 2 * Deviations in MS1 Max For Matching Identified Ions Between Runs", "relative_deviations_in_ms1_max_at_different_rt_quartiles_for_matching_identified_ions_between_runs_single_table"=>"Relative Deviations in MS1 Max at Different RT Quartiles For Matching Identified Ions Between Runs - Single Table", "relative_deviations_in_ms1_max_at_1_rt_quartile_for_matching_identified_ions_between_runs"=>"Relative Deviations in MS1 Max at 1 RT Quartile For Matching Identified Ions Between Runs", 
      "relative_deviations_in_ms1_max_at_2_rt_quartile_for_matching_identified_ions_between_runs"=>"Relative Deviations in MS1 Max at 2 RT Quartile For Matching Identified Ions Between Runs", "relative_deviations_in_ms1_max_at_3_rt_quartile_for_matching_identified_ions_between_runs"=>"Relative Deviations in MS1 Max at 3 RT Quartile For Matching Identified Ions Between Runs", "relative_deviations_in_ms1_max_at_4_rt_quartile_for_matching_identified_ions_between_runs"=>"Relative Deviations in MS1 Max at 4 RT Quartile For Matching Identified Ions Between Runs", "number_of_excess_early_eluting_identified_species"=>"Number of Excess Early Eluting Identified Species", 
      "number_of_excess_late_eluting_identified_species"=>"Number of Excess Late Eluting Identified Species", "peak_widths_at_half_max_at_rt_deciles"=>"Peak widths at half max at RT deciles", "rt_peptide_deciles"=>"RT peptide deciles", "oversampling_vs_rt"=>"Oversampling vs RT", "retention_time_decile_intervals"=>"Retention Time Decile Intervals", "matching_low_high_rt_peptide_ions"=>"Matching Low:High RT Peptide Ions", "rt_median_differences_for_matching_peptides"=>"RT Median Differences for Matching Peptides", "median_dev"=>"Median Dev", "median_skew"=>"Median Skew", "fraction_of_1_rt_decile_peps_in_common"=>"Fraction of 1 RT Decile Peps In Common", 
      "fraction_of_2_rt_decile_peps_in_common"=>"Fraction of 2 RT Decile Peps In Common", "fraction_of_3_rt_decile_peps_in_common"=>"Fraction of 3 RT Decile Peps In Common", "fraction_of_4_rt_decile_peps_in_common"=>"Fraction of 4 RT Decile Peps In Common", "fraction_of_5_rt_decile_peps_in_common"=>"Fraction of 5 RT Decile Peps In Common", "fraction_of_6_rt_decile_peps_in_common"=>"Fraction of 6 RT Decile Peps In Common", "fraction_of_7_rt_decile_peps_in_common"=>"Fraction of 7 RT Decile Peps In Common", "fraction_of_8_rt_decile_peps_in_common"=>"Fraction of 8 RT Decile Peps In Common", "fraction_of_9_rt_decile_peps_in_common"=>"Fraction of 9 RT Decile Peps In Common", 
      "fraction_of_10_rt_decile_peps_in_common"=>"Fraction of 10 RT Decile Peps In Common", "end_interrun_and_decile_results"=>"End Interrun and Decile Results", "ab_deviation_vs_difference_in_run_order"=>"Ab Deviation vs Difference in Run Order - ", "median_rt_rank_vs_difference_in_run_order"=>"Median RT Rank vs Difference in Run Order", "begin_runseries_results"=>"Begin Runseries Results", "begin_series_1"=>"Begin Series=1", "files_analyzed_2"=>"Files Analyzed (2)", "run_number_1_2"=>"Run Number\t1\t2\t", "spectrum_counts"=>"Spectrum Counts", "first_and_last_ms1_rt_min"=>"First and Last MS1 RT (min)", "tryptic_peptide_counts"=>"Tryptic Peptide Counts", 
      "peptide_counts"=>"Peptide Counts", "middle_peptide_retention_time_period_min"=>"Middle Peptide Retention Time Period (min)", "ms1_during_middle_and_early_peptide_retention_period"=>"MS1 During Middle (and Early) Peptide Retention Period", "ms1_total_ion_current_for_different_rt_periods"=>"MS1 Total Ion Current For Different RT Periods", "total_ion_current_for_ids_at_peak_maxima"=>"Total Ion Current For IDs at Peak Maxima", "precursor_m_z_for_ids"=>"Precursor m/z for IDs", "number_of_ions_vs_charge"=>"Number of Ions vs Charge", "averages_vs_rt_for_ided_peptides"=>"Averages vs RT for IDed Peptides", "precursor_m_z_peptide_ion_m_z_2_charge_only_reject_0_45_m_z"=>"Precursor m/z - Peptide Ion m/z (+2 Charge Only, Reject >0.45 m/z)", 
      "ion_ids_by_charge_state_relative_to_2"=>"Ion IDs by Charge State (Relative to +2)", "average_peptide_lengths_for_different_charge_states"=>"Average Peptide Lengths for Different Charge States", "average_peptide_lengths_for_charge_2_for_different_numbers_of_mobile_protons"=>"Average Peptide Lengths For Charge 2 for Different Numbers of Mobile Protons", "numbers_of_ion_ids_at_different_charges_with_1_mobile_proton"=>"Numbers of Ion Ids at Different Charges with 1 Mobile Proton", 
      "percent_of_ids_at_different_charges_and_mobile_protons_relative_to_ids_with_1_mobile_proton"=>"Percent of IDs at Different Charges and Mobile Protons Relative to IDs with 1 Mobile Proton", "precursor_m_z_monoisotope_exact_m_z"=>"Precursor m/z - Monoisotope Exact m/z", "ms2_id_spectra"=>"MS2 ID Spectra", "ms1_id_max"=>"MS1 ID Max", "ms1_id_abund_at_ms2_acquisition"=>"MS1 ID Abund at MS2 Acquisition", "ms2_id_abund_reported"=>"MS2 ID Abund Reported", 
      "max_peak_width_for_ids_sec"=>"Max Peak Width for IDs (sec)", "peak_width_at_half_height_for_ids"=>"Peak Width at Half Height for IDs", "peak_widths_at_half_max_over_rt_deciles_for_ids"=>"Peak Widths at Half Max over RT deciles for IDs", "nearby_resampling_of_ids_oversampling_details"=>"Nearby Resampling of IDs - Oversampling Details", "wide_rt_differences_for_ids_4_min"=>"Wide RT Differences for IDs (> 4 min)", 
      "fraction_of_repeat_peptide_ids_with_divergent_rt_rt_vs_rt_best_id_chromatographic_bleed"=>"Fraction of Repeat Peptide IDs with Divergent RT (RT vs RT-best ID) - Chromatographic 'Bleed'", "early_and_late_rt_oversampling_spectrum_ids_unique_peptide_ids_chromatographic_flow_through_bleed"=>"Early and Late RT Oversampling (Spectrum IDs/Unique Peptide IDs) - Chromatographic: Flow Through/Bleed", 
      "peptide_ion_ids_by_3_spectra_hi_vs_1_3_spectra_lo_extreme_oversampling"=>"Peptide Ion IDs by > 3 Spectra (Hi) vs  1-3 Spectra (Lo) - Extreme Oversampling", "ratios_of_peptide_ions_ided_by_different_numbers_of_spectra_oversampling_measure"=>"Ratios of Peptide Ions IDed by Different Numbers of Spectra - Oversampling Measure", 
      "single_spectrum_peptide_ion_identifications_oversampling_measure"=>"Single Spectrum Peptide Ion Identifications - Oversampling Measure", "ms1max_ms1sampled_abundance_ratio_ids_inefficient_sampling"=>"MS1max/MS1sampled Abundance Ratio IDs - Inefficient Sampling", "rt_ms1max_rt_ms2_for_ids_sec"=>"RT(MS1max)-RT(MS2) for IDs (sec) ", 
      "ion_injection_times_for_ids_ms"=>"Ion Injection Times for IDs (ms)", "relative_fraction_of_peptides_in_retention_decile_matching_a_peptide_in_other_runs"=>"Relative Fraction of Peptides in Retention Decile Matching a Peptide in Other Runs", "relative_uniqueness_of_peptides_in_decile_found_anywhere_in_other_runs"=>"Relative Uniqueness of Peptides in Decile Found Anywhere in Other Runs", "differences_in_elution_rank_percent_of_matching_peptides_in_other_runs"=>"Differences in Elution Rank (Percent) of Matching Peptides in Other Runs", "median_ratios_of_ms1_intensities_of_matching_peptides_in_other_runs"=>"Median Ratios of MS1 Intensities of Matching Peptides in Other Runs", 
      "uncorrected_and_rt_corrected_relative_intensities_of_matching_peptides_in_other_runs"=>"Uncorrected and RT Corrected Relative Intensities of Matching Peptides in Other Runs", "magnitude_of_rt_correction_of_intensities_of_matching_peptides_in_other_runs"=>"Magnitude of RT Correction of Intensities of Matching Peptides in Other Runs", "top_ion_abundance_measures"=>"Top Ion Abundance Measures", "end_series_1"=>"End Series=1", "end_runseries_results"=>"End Runseries Results", "precursor_m_z_averages_at_different_ms1total_tic_quartiles_over_middle_elution_period"=>"Precursor m/z Averages at Different MS1Total (TIC) Quartiles Over Middle Elution Period", "run_q1_precursor_m_z_q2_q1_q3_q1_q4_q1_q1_tic_1000_q2_q1_q3_q1_q4_q1"=>"Run #, Q1 precursor m/z, Q2-Q1, Q3-Q1, Q4-Q1, Q1 TIC/1000, Q2/Q1, Q3/Q1, Q4/Q1", "_1"=>"1", "_2"=>"2", ""=>"", "decile"=>"Decile", 
      "run_1"=>"Run 1", "run_2"=>"Run 2", "run"=>"Run", "median"=>"Median  ", "avg"=>"Avg", "lab_1"=>"Lab 1", "avgdel"=>"AvgDel", "meddel"=>"MedDel", "diff1"=>"Diff1", "ms2_scans"=>"MS2 scans", "ms1_scans_full"=>"MS1 Scans/Full", "ms1_scans_other"=>"MS1 Scans/Other", "first_ms1"=>"First MS1", "last_ms1"=>"Last MS1 ", "peptides"=>"Peptides", "ions"=>"Ions    ", "identifications"=>"Identifications", "abundance_pct"=>"Abundance Pct", "abundance_1000"=>"Abundance/1000", "ions_peptide"=>"Ions/Peptide", "ids_peptide"=>"IDs/Peptide", "semi_tryp_peps"=>"Semi/Tryp Peps", "semi_tryp_cnts"=>"Semi/Tryp Cnts", "semi_tryp_abund"=>"Semi/Tryp Abund", "miss_tryp_peps"=>"Miss/Tryp Peps", "miss_tryp_cnts"=>"Miss/Tryp Cnts", "miss_tryp_abund"=>"Miss/Tryp Abund", "net_oversample"=>"Net Oversample", "half_period"=>"Half Period", 
      "start_time"=>"Start Time", "mid_time"=>"Mid Time", "qratio_time"=>"Qratio Time", "ms1_scans"=>"MS1 Scans", "pep_id_rate"=>"Pep ID Rate", "id_rate"=>"ID Rate ", "id_efficiency"=>"ID Efficiency", "s_n_median"=>"S/N Median", "tic_median_1000"=>"TIC Median/1000", 
      "npeaks_median"=>"NPeaks Median", "scan_to_scan"=>"Scan-to-Scan", "s2s_3q_med"=>"S2S-3Q/Med", "s2s_1qrt_med"=>"S2S-1Qrt/Med", "s2s_2qrt_med"=>"S2S-2Qrt/Med", "s2s_3qrt_med"=>"S2S-3Qrt/Med", "s2s_4qrt_med"=>"S2S-4Qrt/Med", "esi_off_middle"=>"ESI Off Middle", 
      "esi_off_early"=>"ESI Off Early", "max_ms1_jump"=>"Max MS1 Jump", "max_ms1_fall"=>"Max MS1 Fall", "ms1_jumps_10x"=>"MS1 Jumps >10x", "ms1_falls_10x"=>"MS1 Falls >10x", "_1st_quart_id"=>"1st Quart ID", "middle_id"=>"Middle ID", "last_id_quart"=>"Last ID Quart", "to_end_of_run"=>"To End of Run", "med_tic_id_1000"=>"Med TIC ID/1000", 
      "interq_tic"=>"InterQ TIC", "mid_interq_tic"=>"Mid InterQ TIC", "half_width"=>"Half Width", "quart_ratio"=>"Quart Ratio", "precursor_min"=>"Precursor Min", "precursor_max"=>"Precursor Max", "med_q1_tic"=>"Med @ Q1 TIC", "med_q4_tic"=>"Med @ Q4 TIC", "med_q1_rt"=>"Med @ Q1 RT", "med_q4_rt"=>"Med @ Q4 RT", "med_charge_1"=>"Med Charge +1", 
      "med_charge_2"=>"Med Charge +2", "med_charge_3"=>"Med Charge +3", "med_charge_4"=>"Med Charge +4", "charge_1"=>"Charge +1", "charge_2"=>"Charge +2", "charge_3"=>"Charge +3", "charge_4"=>"Charge +4", "charge_5"=>"Charge +5", "length_q1"=>"Length Q1", "length_q4"=>"Length Q4", "charge_q1"=>"Charge Q1", "charge_q4"=>"Charge Q4", "spectra"=>"Spectra ", 
      "mean_absolute"=>"Mean Absolute", "ppm_median"=>"ppm Median", "ppm_interq"=>"ppm InterQ", "_2_ion_count"=>"+2 Ion Count", "naa_ch_2_mp_1"=>"NAA,Ch=2,MP=1", "naa_ch_2_mp_0"=>"NAA,Ch=2,MP=0", "naa_ch_2_mp_2"=>"NAA,Ch=2,MP=2", "ch_1_mp_1"=>"Ch=1 MP=1", 
      "ch_2_mp_1"=>"Ch=2 MP=1", "ch_3_mp_1"=>"Ch=3 MP=1", "ch_4_mp_1"=>"Ch=4 MP=1", "ch_1_mp_0"=>"Ch=1 MP=0", "ch_2_mp_0"=>"Ch=2 MP=0", "ch_3_mp_0"=>"Ch=3 MP=0", "more_than_100"=>"More Than 100", "betw_100_0_50_0"=>"Betw 100.0-50.0", "betw_50_0_25_0"=>"Betw 50.0-25.0", "betw_25_0_12_5"=>"Betw 25.0-12.5", "betw_12_5_6_3"=>"Betw 12.5-6.3", 
      "betw_6_3_3_1"=>"Betw 6.3-3.1", "betw_3_1_1_6"=>"Betw 3.1-1.6", "betw_1_6_0_8"=>"Betw 1.6-0.8", "top_half"=>"Top Half", "next_half_2"=>"Next Half (2)", "next_half_3"=>"Next Half (3)", "next_half_4"=>"Next Half (4)", "next_half_5"=>"Next Half (5)", "next_half_6"=>"Next Half (6)", "next_half_7"=>"Next Half (7)", "next_half_8"=>"Next Half (8)", 
      "npeaks_interq"=>"NPeaks InterQ", "s_n_interq"=>"S/N InterQ", "id_score_median"=>"ID Score Median", "id_score_interq"=>"ID Score InterQ", "idsc_med_q1msmx"=>"IDSc Med Q1Msmx", "median_midrt"=>"Median MidRT", "_75_25_midrt"=>"75/25 MidRT", "_95_5_midrt"=>"95/5 MidRT", "_75_25_pctile"=>"75/25 Pctile", "_95_5_pctile"=>"95/5 Pctile", 
      "median_value"=>"Median Value", "third_quart"=>"Third Quart", "last_decile"=>"Last Decile", "med_top_quart"=>"Med Top Quart", 
      "med_top_16th"=>"Med Top 16th", "med_top_100"=>"Med Top 100", "median_disper"=>"Median Disper", "med_quart_disp"=>"Med Quart Disp", "med_16th_disp"=>"Med 16th Disp", "med_100_disp"=>"Med 100 Disp", "_3quart_value"=>"3Quart Value", "_9dec_value"=>"9Dec Value", "ms1_interscan_s"=>"MS1 Interscan/s", "ms1_scan_fwhm"=>"MS1 Scan/FWHM", 
      "ids_used"=>"IDs Used  ", "first_decile"=>"First Decile", "repeated_ids"=>"Repeated IDs", "med_rt_diff_s"=>"Med RT Diff/s", "_1q_rt_diff_s"=>"1Q RT Diff/s", 
      "_1dec_rt_diff_s"=>"1Dec RT Diff/s", "median_dm_z"=>"Median dm/z", "quart_dm_z"=>"Quart dm/z", "_4_min"=>"+ 4 min      ", "pep_ions_hi"=>"Pep Ions (Hi)", 
      "ratio_hi_lo"=>"Ratio Hi/Lo", "spec_cnts_hi"=>"Spec Cnts (Hi)", "spec_pep_hi"=>"Spec/Pep (Hi)", "spec_cnt_excess"=>"Spec Cnt Excess", "once_twice"=>"Once/Twice", 
      "twice_thrice"=>"Twice/Thrice", "peptide_ions"=>"Peptide Ions", "fract_1_ions"=>"Fract >1 Ions", "_1_vs_1_pepion"=>"1 vs >1 PepIon", "_1_vs_1_spec"=>"1 vs >1 Spec", 
      "median_all_ids"=>"Median All IDs", "_3q_all_ids"=>"3Q All IDs", "_9dec_all_ids"=>"9Dec All IDs", "med_top_dec"=>"Med Top Dec", "med_bottom_1_2"=>"Med Bottom 1/2", 
      "med_diff_abs"=>"Med Diff Abs", "median_diff"=>"Median Diff", "first_quart"=>"First Quart", "ms1_median"=>"MS1 Median", "ms1_maximum"=>"MS1 Maximum", 
      "ms2_median"=>"MS2 Median", "ms2_maximun"=>"MS2 Maximun", "ms2_fract_max"=>"MS2 Fract Max", "all_deciles"=>"All Deciles", "comp_to_first"=>"Comp to First", 
      "comp_to_last"=>"Comp to Last", "average_diff"=>"Average Diff", "median_2_diff"=>"Median*2 Diff", "comp_to_first_2"=>"Comp to First*2", "comp_to_last_2"=>"Comp to Last*2", "uncor_rel_first"=>"Uncor rel First", "uncor_rel_last"=>"Uncor rel Last", 
      "corr_rel_first"=>"Corr rel First", "corr_rel_last"=>"Corr rel Last", "top_10_abund"=>"Top 10% Abund", "top_25_abund"=>"Top 25% Abund", "top_50_abund"=>"Top 50% Abund", "fractab_top"=>"Fractab Top", "fractab_top_10"=>"Fractab Top 10", "fractab_top_100"=>"Fractab Top 100"}
    end #class << self
  end #ComparisonGrapher
end #module Ms
