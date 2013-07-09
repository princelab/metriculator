# requires all of the integrators at the end of the file

class Metriculator
  @@integrations = {}
  @parsed, @db_stored, @finished = false, false, false
  # integration points are: 
  @@names = [:on_db_store, :on_finish, :on_metric_parse]
  @@names.each {|name| @@integrations[name] = [] }
  class << self
    ## Takes procs to run them at the specified integration time.  
    def integration(name, &block)
      if @@names.include? name
        @@integrations[name] << block 
      end
    end
    # Calls stored procs at the database storage moment in msruninfo.rb
    def on_db_store(msrun)
      return if on_db_store?
      @@integrations[:on_db_store].each {|block| block.call msrun }
      @db_stored = true
    end
    # Calls stored procs after everything is done in bin/metriculator (after messaging system)
    def on_finish(msrun)
      return if on_finish?
      @@integrations[:on_finish].each {|block| block.call msrun }
      @finished = true
    end
    # calls stored procs after the parsing is done in metrics.rb, hands back the metric object
    def on_metric_parse(metric)
      return if on_metric_parse?
      @@integrations[:on_metric_parse].each { |block| block.call metric }
      @on_parsed = true
    end
    def on_metric_parse?
      @parsed
    end
    def on_finish?
      @finished
    end
    def on_db_store?
      @db_stored
    end
  end # class << self
end

Dir.glob(File.join(File.dirname(__FILE__), "integrators", "*.rb")).each do |integrator_file|
  require_relative integrator_file
end
