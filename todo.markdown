#This file is a running list of things to accomplish to finish the project

##TODO list (111006)

###Archiver
-	Metric starter fxnality  # TEST THIS!!
*	Message Passing # Mostly done, just clean it up!
* Cron fxnality can be had by the rufus-scheduler gem, which implements cron stuff in ruby.  Looks pretty easy to use.  
		`scheduler = Rufus::Scheduler::PlainScheduler.start_new(:thread_name => 'my scheduler')`
* Colored arrows defining the positive or negative trends when known for each metric
* Make a special viewing page for any graphs that are significantly different (T-test) __????  Would this really help???__

###Website
  - Tracking of what metric comparisons are already produced and available for viewing (Ensure they can't be recreated)
    - Prevent the same comparison from being created multiple times?
      - How can this be done??
    - Maybe it would be best to just create a comparison description that could be user edited and searched?
  - Add breadcrumbs for graph heirarchy?
      -- might be had by the simple "up" link I've added.
  - Pagination is pretty broken
  - figure out how to AJAX update the alerts page

###Database

###Tests
* Why is the integration test stufff not working? MetricsController,
  MsrunsController.
