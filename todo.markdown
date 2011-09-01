#This file is a running list of things to accomplish to finish the project

##TODO list (110805)

###Archiver
-	Metric starter fxnality  # TEST THIS!!
*	Message Passing # Mostly done, just clean it up!
* Cron fxnality can be had by the rufus-scheduler gem, which implements cron stuff in ruby.  Looks pretty easy to use.  
		`scheduler = Rufus::Scheduler::PlainScheduler.start_new(:thread_name => 'my scheduler')`
* EMAIL SMTP ROUTING or I can't test my own email system.
* Use pony gem for email

###Website
  - Server filter AJAX selection list with an Array of desired filterable attributes
  - Tracking of what metric comparisons are already produced and available for viewing (Ensure they can't be recreated)  ??? IS THIS STILL A PROBLEM?
  - Show the graphs
    - Add breadcrumbs for graph heirarchy?
    - When to set the symlink? And do we always assume that they are
      symlinked into the public/ directory?
  - Add support for Alerts which autohide?
  - Pagination is pretty broken

###Database


###Tests
* Why is the integration test stufff not working? MetricsController,
  MsrunsController.
