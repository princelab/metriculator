#This file is a running list of things to accomplish to finish the project

##Ryan's List

###Archiver
-	Metric starter fxnality
*	Archive\_mount needs to handle the message passing
* Archiver needs to handle the configuration loading
-	Each file location is the File.join(@base\_path, @location, directory\_name)
  -	Experiment\_ID???  Is this a necessary type of thing?
* Cron fxnality can be had by the rufus-scheduler gem, which implements cron stuff in ruby.  Looks pretty easy to use.
		`scheduler = Rufus::Scheduler::PlainScheduler.start_new(:thread_name => 'my scheduler')`

###Website
  -	Server filter AJAX selection list
  -	Integrated production of different metrics
  -	Tracking of what metric comparisons are already produced and available for viewing
  -	How do I store the sets of metric images best?
		- embedded svgs?
		- libraries of svg files?

###Database
-	Category.hashes level implementation of the cleaning up of the output hash(removing the id and general filepath details)
  -	Experiment\_ID 
		-	value that will implement a way to annotate all experiment sets into a single ID code (ryanmt_xlink_01) (name_experiment-name_id#)


##DataMapper pagination stuff
  if I was going to build a pagination lib today I would build on top of dm-chunked_query
  [4:42pm] postmodern joined the chat room.
  [4:48pm] dkubb: postmodern: are you aware of any pagination libs built on top of your dm-chunked_query lib?
  [4:53pm] postmodern: dkubb, nope
  [4:54pm] postmodern: dkubb, will_paginate rails3 branch has a bug, but a coworker submitted a patch
  [4:54pm] postmodern: dkubb, they were to_a'ing the DM Collection
  [4:54pm] dkubb: postmodern: ahh ok. since your does the heavy lifting it's what I've been recommending to people to base paginating off, instead of going with one of the random other ones
  [4:54pm] postmodern: dkubb, i would love to see some pagination helpers built ontop of dm-chunked\_query
  [4:55pm] postmodern: dkubb, it's only a matter of making the partials for the controls, and a bit of code to consume `params[:page]` or `params[:per_page]`
  [4:55pm] dkubb: postmodern: right, so wiring up the HTML output
[4:56pm] postmodern: @page = `Model.query.chunks(params.fetch(:per_page, 10)).at(params.fetch(:page, 1) - 1)`
  [4:56pm] dkubb: beautiful


**note:** Due to some weirdness with datamapper + my inexperience with
it, if you are trying to add a run to a comparison, the comparison won't
show up on the run unless you add it there as well. For example, 

```ruby
  comparison.msrun_firsts << run
  comparison.save
  run.comparison_firsts << comparison
  run.save
```

* Fix pagination when there is only one page
* Implement ajax adding stuff to comparisons
* Figure out why I have to add ```require 'archiver'```. Shouldn't it be done automatically for me?
* pagination is still pretty wonky. Take a look at that also.
